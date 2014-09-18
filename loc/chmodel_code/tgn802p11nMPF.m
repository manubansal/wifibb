function h = tgn802p11nMPF(Nt,Nr,ts,tau,pdb,AoA,AS_Rx,AoD,AS_Tx,K)
% function h = mpf802_11n(Nt,Nr,ts,tau,pdb,AoA,AS_Rx,AoD,AS_Tx,K) <- old
% name
%% IEEE 802.11n Channel Models
% This demo shows how to simulate multiple-input multiple-output (MIMO)
% multipath fading channels based on the IEEE(R) 802.11n channel models for 
% indoor wireless local area networks (WLAN). Two transmit antennas and two
% receive antennas are used. The demo uses the MIMO multipath fading
% channel and the bell Doppler spectrum objects.

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/05/23 07:50:06 $

%% Initialization of Simulation-Specific Parameters 
% The simulation sampling rate is specified, and kept the same for the
% remainder of the demo.  The input to the channel simulator is oversampled
% by a factor of four.

% S = RandStream('swb2712', 'Seed', seednum); % Set a local random number stream
% ts = ;        % Input sample period

%% Channel Model B
% The code below constructs a MIMO channel object according to channel
% model B of [ <#10 1> ], in non-line-of-sight (NLOS) mode.
%
% This channel model has 9 Rayleigh-fading paths, and each path has a bell
% Doppler spectrum, with a parameter as specified in the default
% doppler.bell object. 
%
% We use two transmit antennas and two receive antennas. For each path, the
% transmit and receive correlation matrices are calculated according to the
% procedure given in [ <#10 1> ], [ <#10 2> ]. 

% Nt = 2;                     % Number of transmit antennas
% Nr = 4;                     % Number of receive antennas
warning off all;
fd =  3;                     % Maximum Doppler shift for all paths (identical)

dop = doppler.bell;         % Bell doppler spectrum, with default parameters

% tau = [0 10 20 30 40 50 60 70 80] * 1e-9;   % Path delays, in seconds
% % Np = length(tau);                           % Number of paths

% % Average path gains of cluster 1, in dB
% pdb1 = [0 -5.4 -10.8 -16.2 -21.7 -inf -inf -inf -inf];      
% % Average path gains of cluster 2, in dB
% pdb2 = [-inf -inf -3.2 -6.3 -9.4 -12.5 -15.6 -18.7 -21.8];
% Total average path gains for both clusters, in dB
pdlin = 10.^(pdb/10);

% pdbsum = 10*log10(10.^(pdb1/10)+10.^(pdb2/10));
pdbsum = 10*log10(sum(pdlin,1)); 

% Element spacing at the transmit and receive antennas (normalized by the
% wavelength)
TxSpacing = 0.5;
RxSpacing = 0.5;

% % Spatial parameters on transmitter side:
% %   Angular spreads - Cluster 1
% AS_Tx_C1 = [14.4 14.4 14.4 14.4 14.4 -inf -inf -inf -inf];        
% %   Angular spreads - Cluster 2
% AS_Tx_C2 = [-inf -inf 25.4 25.4 25.4 25.4 25.4 25.4 25.4];        
% %   Mean angles of departure - Cluster 1
% AoD_C1 = [225.1 225.1 225.1 225.1 225.1 -inf -inf -inf -inf];     
% %   Mean angles of departure - Cluster 2
% AoD_C2 = [-inf -inf 106.5 106.5 106.5 106.5 106.5 106.5 106.5];   

% Spatial parameters on receiver side:
%   Angular spreads - Cluster 1
% AS_Rx_C1 = [14.4 14.4 14.4 14.4 14.4 -inf -inf -inf -inf];        
%   Angular spreads - Cluster 2
% AS_Rx_C2 = [-inf -inf 25.2 25.2 25.2 25.2 25.2 25.2 25.2];        
%   Mean angles of arrival - Cluster 1
% AoA_C1 = 30+[4.3 4.3 4.3 4.3 4.3 -inf -inf -inf -inf];               
%   Mean angles of arrival - Cluster 2
% AoA_C2 = -178+[-inf -inf 118.4 118.4 118.4 118.4 118.4 118.4 118.4];   

% Calculation of transmit and receive correlation arrays
% tic
[TxCorrelationMatrix, RxCorrelationMatrix] = ...
    tgn802p11nCorrMatrix(Nt,Nr,TxSpacing,RxSpacing,pdb,AoA,AS_Rx,AoD,AS_Tx);
% toc
% tic
h = mimochan(Nt, Nr, ts, fd, tau, pdbsum);   % MIMO channel object
% toc
% warnStruct = warning('query','last');
% msgid_integerCat = warnStruct.identifier;
% warning('off',msgid_integerCat);

h.KFactor = K;                               % Rician K-factor on first path
h.DopplerSpectrum = dop;                     % Doppler spectrum of MIMO object

if Nt > 1   
 h.TxCorrelationMatrix = TxCorrelationMatrix; % Transmit correlation array
end
if Nr > 1
%  RxCorrelationMatrix(abs(RxCorrelationMatrix)>1)   = 1; 
 h.RxCorrelationMatrix = RxCorrelationMatrix; % Transmit correlation array
end
%%
% The code below simulates the effect of the MIMO channel on a random 
% input sequence.

% After each frame is processed, the channel is not reset: this is 
% necessary to preserve continuity across frames.
h.ResetBeforeFiltering = 1;
% This setting is needed to store the path gains.
h.StorePathGains = 1;

% Nchan = 100; %Number of channel
% Nires = 80; %Lenth of impulse response in terms of the sampling period Ts
% h_chan = zeros(Nchan,Nires); %Stor all the impulse response here
%  for i=1:Nchan
%  inputSig = [1;zeros(Nires-1,1)];% modulate(hModem, [1;zeros(Nires-1,1)]);
% 
%  h_chan(i,:) =filter(h,inputSig)'; 
% %  link11(idx,ip) = h.PathGains(:,i,1,1);
%  end 
% tt = 0:ts:(Nires-1)*ts;
% plot(tt,abs(h_chan)');


end