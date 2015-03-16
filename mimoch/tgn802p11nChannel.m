function out = tgn802p11nChannel(Nt,Nr,d,ts,in,SNR,seednum,AoAnew,type)

% function out = channel802_11n(Nt,Nr,d,ts,in,SNR,seednum,AoAnew,type) <-
% old name
%Applied the TGn 802.11n model to the input stream
%d: distance between the tx-rx
%ts: sampling interval
%in:input vector to the channel
%SNR: SNR at the output of the channel
%seednum: seednumber to control the Gaussian noise
%type: Valid input A-F represnting the ModelA-F of 802.11n, TGn model
%Aoanew = mean Angle of Arrival of the first cluster, all the remaining AOA
%will be adjusted with relative to the first AOA

%Model : Number of clusters
%A: 1 
%B: 2
%C: 2
%D: 3
%E: 4
%F: 6

% nmaxc = length(AoAnew);
% if nmaxc >0 
% switch type
%     case 'A'
%         if(nmaxc ~= 1)
%             disp(['Invalid number of AOA, Valid number for model ' type ' is 1'])
%             exit
%         end
%         
%     case 'B'
%         if(nmaxc ~= 2)
%             disp(['Invalid number of AOA, Valid number for model ' type ' is 2'])
%             exit
%         end
%         
%     case 'C'
%         if(nmaxc ~= 2)
%             disp(['Invalid number of AOA, Valid number for model ' type ' is 2'])
%             exit
%         end
%     case 'D'
%         if(nmaxc ~= 3)
%             disp(['Invalid number of AOA, Valid number for model ' type ' is 3'])
%             exit
%         end
%     case 'E'
%         if(nmaxc ~= 4)
%             disp(['Invalid number of AOA, Valid number for model ' type ' is 4'])
%             exit
%         end
%     case 'F'
%         if(nmaxc ~= 6)
%             disp(['Invalid number of AOA, Valid number for model ' type ' is 6'])
%             exit
%         end
% end 
% end

%Load the data
[tau,pdb,AoA,AS_Rx, AoD, AS_Tx,K] = tgn802p11nData(d,type);

AoAref =AoA(1,1);

%Replace by new AOA if present
for ai =1:size(AoA,1)
    AoA(ai,isfinite(AoA(ai,:))) = mod(AoA(ai,isfinite(AoA(ai,:))) + AoAnew-AoAref,360);
end
 
%Apply path loss
Lpl = tgn802p11nPL(d,seednum,type,0);
spl = 10.^(-Lpl/20);
ypl = spl*in; %Scale by path loss parameter

%Apply multipath fading
% tic
h= tgn802p11nMPF(Nt,Nr,ts,tau,pdb,AoA,AS_Rx,AoD,AS_Tx,K);
% toc
% tic
ympf = filter(h,repmat(ypl,1,Nt)); %Apply input to the 
%  toc
%Apply AWGN channel
out = awgn(ympf,SNR,'measured'); 

end