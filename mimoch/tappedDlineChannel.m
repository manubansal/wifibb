function signal =tappedDlineChannel(di,si,thetai,fc,M,x)
% function signal =multipathch(di,si,thetai,fc,M,x) <- old name

%Tapped delay line channel with time invariant tap coefficients

%Generates a multipath model with the specified delay, scaling factor and angle of arrival 

%di: delay in unit of 1/fs
%si: relative scaling
%thetai: AOA for different multipaths in degree
%fs: sampling frequency
%fc: carrier frequency
%M: number of antennas in the array
%x: signal at the transmitter

%y = sum_i si*a(thetai)*x(t-di)
addpath('../../arraymodel/v1')
x = x(:);
lambda = 3e8/fc;                   % Wavelength
% D = 2*lambda;                      % Total Array Length
d = lambda/2;%0.0625;%lambda/2;                      % Array Placement Distance
% M = D/d;                           % Number of Array Elements
signal = zeros(length(x),M);
for i = 1:length(thetai)
    xd = si(i)*[zeros(di(i),1);x(1:end-di(i))];
    signal = signal+xd*steering_vector_ula(M,thetai(i),d,lambda).';
end


end