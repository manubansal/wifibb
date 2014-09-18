function [out,ympfsig,ympfint_prx,SNR,SINR] = tgn802p11nChannel2(Nt,Nr,d,ts,type,pnrx,xsig,psigtx,AoAsig,xint,pintrx,AoAint,seednum)

%Apply TGn 802.11n model to the input stream xsig and the interference
%stream xint

%d: distance between the tx-rx for the signal
%    distance feature is not needed for the interference because the 
%    interference power at the receiver is specified as an input to this 
%    function, therefore no need to specify the distance between the source
%    of interference and the receiver
%ts: sampling interval
%type: Valid input A-F represnting the ModelA-F of 802.11n, TGn model
%pnrx : power of the noise added at the receiver in dBm 
%       there are two ways to find this:
%    1) if the noise figure of the receiver is known then noise power can
%       be added by simply adding the noise of ideal receiver and the noise
%       figure, pnrx|dBm = Nf|dB + pnideal|dBm,
%       where , pnideal|dBm = 10*log10(k*T0*B*10^3) 
%                          = 10*log10(k*T0*B)+30
%    2) if the receiver sensitivity is known and the minimum SNR to
%    establish a communication is known then the noise power can be
%    obtained using the following,
%    pminrx|dBm = SNR_min|dB + Nf|dB + pnideal|dBm
%    where,
%    pminrx is receiver sensitivity in dBm
%    SNR_min: minimum SNR in dB needed for a communication to be
%             established between tx-rx at a given data rate
%    pnrx = Nf+pnideal : is the noise power of the real receiver in dBm
               
%xsig:sigal input vector to the channel
%psigtx: power of the signal at the transmitter in dBm (at input of channel)
%Aoasig = mean Angle of Arrival of the first cluster of the signal, 
%         all the remaining AOA will be adjusted with relative to the first
%         AOA 
%xint: interference input vector to the channel
%pintrx: power of the interference at the receiver in dBm
%AoAint: mean Angle of Arrival of the first cluster of the interference
%seednum: seednumber to control the Gaussian noise

%OUTPUT:

%out : received signal with added interference and the receiver noise
%SNR: 10*log10(psigrx/pnrx) Sinal to noise ratio at the recevier
%SINR: 10*log10(psigrx/(pintrx + pnrx)) Signal to noise plus interference
%                                       ratio at the receiver, here the
%                                       psigrx is dependent on the transmit
%                                       power psigtx, distance d between
%                                       tx-rx and the channel type 


%Model : Number of clusters
%A: 1 
%B: 2
%C: 2
%D: 3
%E: 4
%F: 6


%Load the data
[tau,pdb,AoA,AS_Rx, AoD, AS_Tx,K] = tgn802p11nData(d,type);

AoAref =AoA(1,1);

AoAs = -inf*ones(size(AoA));
%Replace by new AOA for the signal
for ai =1:size(AoA,1)
    AoAs(ai,isfinite(AoA(ai,:))) = mod(AoA(ai,isfinite(AoA(ai,:))) + AoAsig-AoAref,360);
end

AoAi = -inf*ones(size(AoA));
%Replace by new AOA for the interference
for ai =1:size(AoA,1)
    AoAi(ai,isfinite(AoA(ai,:))) = mod(AoA(ai,isfinite(AoA(ai,:))) + AoAint-AoAref,360);
end
 
%Apply transmiter power and the path loss to signal
stx = 10^((psigtx - 30)/20); %first convert the transmit power to dB from dBm
                             %then convert to the linear scaling parameter
psig = mean(abs(xsig).^2);   %Mean signal power in Watts
xsig_unit = xsig/sqrt(psig); %Convert signal into signal with unit power (1 W = 0dB =30dBm)
xsig_ptx  = xsig_unit*stx;   %Convert signal into signal with tx power psigtx |dBm
Lpl = tgn802p11nPL(d,seednum,type,0); %path loss in dB
spl = 10.^(-Lpl/20);
ypl = spl*xsig_ptx; %Scale by path loss parameter, 
                    %the average received power of ypl has to be roughly
                    %equal to psigtx - Lpl , i.e 
                    %10*log10(mean(abs(ypl).^2)) + 30 has to equal to
                    %psigtx - Lpl



%Apply multipath fading for signal
% tic
hsig= tgn802p11nMPF(Nt,Nr,ts,tau,pdb,AoAs,AS_Rx,AoD,AS_Tx,K);
% toc
% tic
%Apply multipath fading for interference
hint= tgn802p11nMPF(Nt,Nr,ts,tau,pdb,AoAi,AS_Rx,AoD,AS_Tx,K);

ympfsig = filter(hsig,repmat(ypl,1,Nt)); %Apply signal input to the channel
ympfint = filter(hint,repmat(xint,1,Nt));%Apply interference to the channel

%Apply received power to the interference
srx = 10^((pintrx - 30)/20); %Convert it to dB from dBm and then convert to 
                            %the linear scaling parameter
pint = mean(abs(ympfint(:,1)).^2); %Mean power of the interference source at the first antenna
ympfint_unit = ympfint/sqrt(pint); %Convert signal into signal with unit power (1 W = 0dB =30dBm)
ympfint_prx  = ympfint_unit*srx;   %Convert signal into signal with rx power pintrx |dBm
                                   %verify this by computing
                                   %10*log10(mean(abs(ympfint_prx).^2))+30
psigrx_W = mean(abs(ympfsig(:,1)).^2); %Received power of the signal at the first antenna in Watts
psigrx_dB = 10*log10(psigrx_W); %Received power of the signal at the first antenna

pnrx_W = 10^((pnrx - 30)/10); %Noise power in Watts

pnrx_pintrx_W = pnrx_W + srx^2; %Noise plus signal power in Watts
pnrx_pintrx_dB = 10*log10(pnrx_pintrx_W);

SNR = psigrx_dB - (pnrx - 30); %SNR in dB
%  toc
%Apply AWGN channel
ysig_noise = awgn(ympfsig,SNR,psigrx_dB);%'measured'); 

SINR = psigrx_dB - pnrx_pintrx_dB;  %SINR in dB
%Add the interference to the output
out = ysig_noise + ympfint_prx;
end