function L= tgn802p11nPL(d,seednum,type,plotfig)
% function L= pl802_11n(d,seednum,type,plotfig) <-- Old name

%Models Path loss model given by 802.11 TGn model
%Models the free space path loss and the log normal shadowing
%d: distance between AP's in meter
%seednum: seed for random number
%L: Path loss and log-normal shadowing components in (dB)
%type: Valid strigs are A-F, representing model A -F of 802.11n TGn model

M = length(d); %Number of TxAP-RxAP pairs, note this doesnot refer to 
               %the number of antenna's in each AP's 
d = d(:); %convert to column vector               
               
%L0: Free space path loss at distance of d0 (meter) (wireless lan comes of
%age: understanding 802.11n ammendments)
Gt= 1; %Gain of the transmitter antenna
Gr=1; %Gain of the receiver antenna
d0=1; %Reference distance
c = 3e8; %Speed of light
fc=5.25e9;%Carrier frequency
lambda=c/fc; %wavelength
L0 = 10*log10( (1/(Gt*Gr))*(4*pi*d0/lambda)^2);

switch type
    case 'A'
        %Model A
        dBP = 5;
        alpha1 = 2;
        alpha2 = 3.5;
        sigma1 = 3; 
        sigma2 = 4;        
        
    case 'B'
        %Model B
        dBP = 5;
        alpha1 = 2;
        alpha2 = 3.5;
        sigma1 = 3; 
        sigma2 = 4;
        
    case 'C'
        %Model C
        dBP = 5;
        alpha1 = 2;
        alpha2 = 3.5;
        sigma1 = 3; 
        sigma2 = 5;        
    case 'D'
        %Model D
        dBP = 10;
        alpha1 = 2;
        alpha2 = 3.5;
        sigma1 = 3; 
        sigma2 = 5;        
    case 'E'
        %Model E
        dBP = 20;
        alpha1 = 2;
        alpha2 = 3.5;
        sigma1 = 3; 
        sigma2 = 6;        
    case 'F'
        %Model F
        dBP = 30;
        alpha1 = 2;
        alpha2 = 3.5;
        sigma1 = 3; 
        sigma2 = 6;        
end       
      


randn('seed',seednum);
X1 = sigma1*randn(M,1);
X2 = sigma2*randn(M,1);

LFS1 = L0 + 10*alpha1*log10(d);
LFS2 = L0 + 10*alpha1*log10(dBP);
L1 = LFS1 + X1;
L2 = LFS2 + 10*alpha2*log10(d/dBP) + X2;
L(d<=dBP) = L1(d<=dBP);
L(d>dBP)  = L2(d>dBP);


if plotfig
figure
semilogx(d,L)
title('Path gain vs distance with Path loss and log normal shadowing')
xlabel('distance(m)')
ylabel('Pathgain or RSS(dB)')
grid on

end
end