function [tau,pdb,AoA,AS_Rx, AoD, AS_Tx,K] = tgn802p11nData(d,type)
% function [tau,pdb,AoA,AS_Rx, AoD, AS_Tx,K] = tgn802p11data(d,type) <- old
% name
%d: Distance between the transmitter and the receiver
%Type : Type of channel model
%Model : Number of clusters
%A: 1
%B: 2
%C: 2
%D: 3
%E: 4
%F: 6


switch type
    case 'A'
        % Tap index 1 
        % Excess delay [ns]
        tau = 0; 
        % Power [dB]
        pdb = 0; 
        % AoA AoA [?]
        AoA = 45; 
        % AS (receiver) AS [?]
        AS_Rx = 40; 
        % AoD AoD [?]
        AoD = 45; 
        %  AS (transmitter) AS [?]
        AS_Tx = 40; 
        
        dBP = 5;
        K = 10^(-inf/10);  %NLOS
        if (d<dBP)
            K=10^(0/10); %LOS
        end
               
    case 'B'
        tau = [0 10 20 30 40 50 60 70 80] * 1e-9;  
        % Average path gains of cluster 1, in dB
        pdb1 = [0 -5.4 -10.8 -16.2 -21.7 -inf -inf -inf -inf];      
        % Average path gains of cluster 2, in dB
        pdb2 = [-inf -inf -3.2 -6.3 -9.4 -12.5 -15.6 -18.7 -21.8];
        pdb = [pdb1;pdb2];

        % Spatial parameters on transmitter side:
        %   Angular spreads - Cluster 1
        AS_Tx_C1 = [14.4 14.4 14.4 14.4 14.4 -inf -inf -inf -inf];        
        %   Angular spreads - Cluster 2
        AS_Tx_C2 = [-inf -inf 25.4 25.4 25.4 25.4 25.4 25.4 25.4];   
        AS_Tx = [AS_Tx_C1;AS_Tx_C2];
        
        %   Mean angles of departure - Cluster 1
        AoD_C1 = [225.1 225.1 225.1 225.1 225.1 -inf -inf -inf -inf];     
        %   Mean angles of departure - Cluster 2
        AoD_C2 = [-inf -inf 106.5 106.5 106.5 106.5 106.5 106.5 106.5];   
        AoD = [AoD_C1;AoD_C2];
        
        % Spatial parameters on receiver side:
        %   Angular spreads - Cluster 1
        AS_Rx_C1 = [14.4 14.4 14.4 14.4 14.4 -inf -inf -inf -inf];        
        %   Angular spreads - Cluster 2
        AS_Rx_C2 = [-inf -inf 25.2 25.2 25.2 25.2 25.2 25.2 25.2]; 
        AS_Rx = [AS_Rx_C1;AS_Rx_C2];
        
        %   Mean angles of arrival - Cluster 1
        AoA_C1 = [4.3 4.3 4.3 4.3 4.3 -inf -inf -inf -inf];               
        %   Mean angles of arrival - Cluster 2
        AoA_C2 = [-inf -inf 118.4 118.4 118.4 118.4 118.4 118.4 118.4];   
        AoA = [AoA_C1;AoA_C2];
        
        dBP = 5;
        K = 10^(-inf/10);  %NLOS
        if (d<dBP)
            K=10^(0/10); %LOS
        end
        
    case 'C'
        
        %Excess delay [ns] 
        tau = [0 10 20 30 40 50 60 70 80 90 110 140 170 200]*1e-9;
        
        %Cluster 1 Power [dB]
        pdb1 = [0 -2.1 -4.3 -6.5 -8.6 -10.8 -13.0 -15.2 -17.3 -19.5 -inf -inf -inf -inf];
        %Cluster 2 Power [dB]
        pdb2 = [-inf -inf -inf -inf -inf -inf -5.0 -7.2 -9.3 -11.5 -13.7 -15.8 -18.0 -20.2 ];
        pdb = [pdb1;pdb2];
        
        %AS (receiver) AS [?]
        AS_Rx_C1 = [24.6 24.6 24.6 24.6 24.6 24.6 24.6 24.6 24.6 24.6 -inf -inf -inf -inf]; 
        %AS AS [?]
        AS_Rx_C2 = [ -inf -inf -inf -inf -inf -inf 22.4 22.4 22.4 22.4 22.4 22.4 22.4 22.4]; 
        AS_Rx = [AS_Rx_C1; AS_Rx_C2];
        
        %AS (transmitter) AS [?]
        AS_Tx_C1 = [24.7 24.7 24.7 24.7 24.7 24.7 24.7 24.7 24.7 24.7 -inf -inf -inf -inf];
        %AS AS [?]
        AS_Tx_C2 = [-inf -inf -inf -inf -inf -inf 22.5 22.5 22.5 22.5 22.5 22.5 22.5 22.5]; 
        AS_Tx = [AS_Tx_C1; AS_Tx_C2];
        
        %AoA AoA [?]
        AoA_C1 = [290.3 290.3 290.3 290.3 290.3 290.3 290.3 290.3 290.3 290.3 -inf -inf -inf -inf ];
        %AoA AoA [?]
        AoA_C2 = [-inf -inf -inf -inf -inf -inf 332.3 332.3 332.3 332.3 332.3 332.3 332.3 332.3 ];
        AoA = [AoA_C1; AoA_C2];
        
        %AoD AoD [?]
        AoD_C1 = [13.5 13.5 13.5 13.5 13.5 13.5 13.5 13.5 13.5 13.5 -inf -inf -inf -inf];
        %AoD AoD [?]
        AoD_C2= [-inf -inf -inf -inf -inf -inf 56.4 56.4 56.4 56.4 56.4 56.4 56.4 56.4 ];
        AoD  = [AoD_C1; AoD_C2];
        
        dBP = 5;
        K = 10^(-inf/10);  %NLOS
        if (d<dBP)
            K=10^(0/10); %LOS
        end
        
    case 'D'
        %Model D 
        %Tap index 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 
        %Excess delay [ns]
        tau = [0 10 20 30 40 50 60 70 80 90 110 140 170 200 240 290 340 390 ]*1e-9;
        %Cluster 1 Power [dB] 
        pdb1 = [0 -0.9 -1.7 -2.6 -3.5 -4.3 -5.2 -6.1 -6.9 -7.8 -9.0 -11.1 -13.7 -16.3 -19.3 -23.2 -inf -inf];
        %AoA AoA [?]
        AoA_C1 = [158.9 158.9 158.9 158.9 158.9 158.9 158.9 158.9 158.9 158.9 158.9 158.9 158.9 158.9 158.9 158.9 -inf -inf]; 
        %AS (receiver) AS [?]
        AS_Rx_C1 = [ 27.7 27.7 27.7 27.7 27.7 27.7 27.7 27.7 27.7 27.7 27.7 27.7 27.7 27.7 27.7 27.7  -inf -inf];
        %AoD AoD [?]
        AoD_C1 = [332.1 332.1 332.1 332.1 332.1 332.1 332.1 332.1 332.1 332.1 332.1 332.1 332.1 332.1 332.1 332.1  -inf -inf];
        %AS (transmitter) AS [?]
        AS_Tx_C1 = [ 27.4 27.4 27.4 27.4 27.4 27.4 27.4 27.4 27.4 27.4 27.4 27.4 27.4 27.4 27.4 27.4  -inf -inf];
        %Cluster 2 Power [dB] 
        pdb2 = [ -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -6.6 -9.5 -12.1 -14.7 -17.4 -21.9 -25.5 -inf ];
        %AoA AoA [?]
        AoA_C2 = [ -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 320.2 320.2 320.2 320.2 320.2 320.2 320.2 -inf];
        %AS AS [?]
        AS_Rx_C2 = [ -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 31.4 31.4 31.4 31.4 31.4 31.4 31.4  -inf];
        %AoD AoD [?]
        AoD_C2 = [ -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 49.3 49.3 49.3 49.3 49.3 49.3 49.3  -inf];
        %AS AS [?]
        AS_Tx_C2 =[ -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 32.1 32.1 32.1 32.1 32.1 32.1 32.1  -inf];
        %Cluster 3 Power [dB]
        pdb3 =[ -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -18.8 -23.2 -25.2 -26.7 ];
        %AoA AoA [?]
        AoA_C3 = [  -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 276.1 276.1 276.1 276.1 ];
        %AS AS [?]
        AS_Rx_C3 = [  -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 37.4 37.4 37.4 37.4]; 
        %AoD AoD [?]
        AoD_C3 = [  -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 275.9 275.9 275.9 275.9 ];
        %AS AS [?]
        AS_Tx_C3 = [  -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 36.8 36.8 36.8 36.8]; 

        pdb = [pdb1; pdb2; pdb3];
        AoA = [AoA_C1; AoA_C2;AoA_C3];
        AS_Rx = [AS_Rx_C1; AS_Rx_C2;AS_Rx_C3];
        AoD  = [AoD_C1; AoD_C2;AoD_C3];
        AS_Tx = [AS_Tx_C1; AS_Tx_C2;AS_Tx_C3];

        dBP = 10;
        K = 10^(-inf/10);  %NLOS
        if (d<dBP)
            K=10^(3/10); %LOS
        end
        
    case 'E'
        %Appendix C - Model E (1/2) 
        %Tap index 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 
        %Excess delay [ns]
        tau = [ 0 10 20 30 50 80 110 140 180 230 280 330 380 430 490 560 640 730 ]*1e-9;
        % Cluster 1 Power [dB]
        pdb1 =[ -2.6 -3.0 -3.5 -3.9 -4.5 -5.6 -6.9 -8.2 -9.8 -11.7 -13.9 -16.1 -18.3 -20.5 -22.9 -inf -inf -inf ];
        % AoA AoA [?]
        AoA_C1 = [ 163.7 163.7 163.7 163.7 163.7 163.7 163.7 163.7 163.7 163.7 163.7 163.7 163.7 163.7 163.7 -inf -inf -inf ];
        % AS (receive) AS [?]
        AS_Rx_C1 = [ 35.8 35.8 35.8 35.8 35.8 35.8 35.8 35.8 35.8 35.8 35.8 35.8 35.8 35.8 35.8 -inf -inf -inf ];
        % AoD AoD [?]
        AoD_C1= [ 105.6 105.6 105.6 105.6 105.6 105.6 105.6 105.6 105.6 105.6 105.6 105.6 105.6 105.6 105.6 -inf -inf -inf ];
        % AS (transmit) AS [?]
        AS_Tx_C1 = [ 36.1 36.1 36.1 36.1 36.1 36.1 36.1 36.1 36.1 36.1 36.1 36.1 36.1 36.1 36.1 -inf -inf -inf ];
        %Cluster 2 Power [dB]
         pdb2 = [-inf -inf -inf -inf -1.8 -3.2 -4.5 -5.8 -7.1 -9.9 -10.3 -14.3 -14.7 -18.7 -19.9 -22.4 -inf -inf ];
        %AoA AoA [?]
         AoA_C2 = [-inf -inf -inf -inf 251.8 251.8 251.8 251.8 251.8 251.8 251.8 251.8 251.8 251.8 251.8 251.8  -inf -inf];
        % AS AS [?]
         AS_Rx_C2= [-inf -inf -inf -inf 41.6 41.6 41.6 41.6 41.6 41.6 41.6 41.6 41.6 41.6 41.6 41.6  -inf -inf];
        % AoD AoD [?]
        AoD_C2 = [ -inf -inf -inf -inf 293.1 293.1 293.1 293.1 293.1 293.1 293.1 293.1 293.1 293.1 293.1 293.1  -inf -inf];
        % AS AS [?]
        AS_Tx_C2 = [ -inf -inf -inf -inf 42.5 42.5 42.5 42.5 42.5 42.5 42.5 42.5 42.5 42.5 42.5 42.5 -inf -inf]; 

        % Cluster 3 Power [dB]
         pdb3 = [-inf -inf -inf -inf -inf -inf -inf -inf -7.9 -9.6 -14.2 -13.8 -18.6 -18.1 -22.8 -inf -inf -inf ]; 
        % AoA AoA [?]
         AoA_C3 = [-inf -inf -inf -inf -inf -inf -inf -inf 80.0 80.0 80.0 80.0 80.0 80.0 80.0 -inf -inf -inf]; 
        % AS AS [?]
         AS_Rx_C3 = [-inf -inf -inf -inf -inf -inf -inf -inf 37.4 37.4 37.4 37.4 37.4 37.4 37.4  -inf -inf -inf];
        % AoD AoD [?]
         AoD_C3 = [-inf -inf -inf -inf -inf -inf -inf -inf 61.9 61.9 61.9 61.9 61.9 61.9 61.9  -inf -inf -inf];
        % AS AS [?]
         AS_Tx_C3 = [-inf -inf -inf -inf -inf -inf -inf -inf 38.0 38.0 38.0 38.0 38.0 38.0 38.0  -inf -inf -inf];
        % Cluster 4 Power [dB]
         pdb4 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -20.6 -20.5 -20.7 -24.6 ];
        % AoA AoA [?]
         AoA_C4 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 182.0 182.0 182.0 182.0 ];
        % AS AS [?]
         AS_Rx_C4 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 40.3 40.3 40.3 40.3 ];
        % AoD AoD [?]
         AoD_C4 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 275.7 275.7 275.7 275.7 ];
        % AS AS [?]
         AS_Tx_C4 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 38.7 38.7 38.7 38.7 ];

        pdb = [pdb1; pdb2; pdb3;pdb4];
        AoA = [AoA_C1; AoA_C2;AoA_C3;AoA_C4];
        AS_Rx = [AS_Rx_C1; AS_Rx_C2;AS_Rx_C3;AS_Rx_C4];
        AoD  = [AoD_C1; AoD_C2;AoD_C3;AoD_C4];
        AS_Tx = [AS_Tx_C1; AS_Tx_C2;AS_Tx_C3;AS_Tx_C4];
        
        dBP = 20;
        K = 10^(-inf/10);  %NLOS
        if (d<dBP)
            K=10^(6/10); %LOS
        end
        
    case 'F'
        
        % Model F (1/2) 
        % Tap index 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 
        % Excess delay [ns]
         tau = [0 10 20 30 50 80 110 140 180 230 280 330 400 490 600 730 880 1050 ]*1e-9;
        % Cluster 1 Power [dB]
        pdb1 = [ -3.3 -3.6 -3.9 -4.2 -4.6 -5.3 -6.2 -7.1 -8.2 -9.5 -11.0 -12.5 -14.3 -16.7 -19.9 -inf -inf -inf  ];
        % AoA AoA [?]
         AoA_C1 = [315.1 315.1 315.1 315.1 315.1 315.1 315.1 315.1 315.1 315.1 315.1 315.1 315.1 315.1 315.1 -inf -inf -inf ];
        % AS (receive) AS [?]
         AS_Rx_C1= [48.0 48.0 48.0 48.0 48.0 48.0 48.0 48.0 48.0 48.0 48.0 48.0 48.0 48.0 48.0 -inf -inf -inf ];
        % AoD AoD [?]
         AoD_C1= [56.2 56.2 56.2 56.2 56.2 56.2 56.2 56.2 56.2 56.2 56.2 56.2 56.2 56.2 56.2 -inf -inf -inf ];
        % AS (transmit) AS [?]
         AS_Tx_C1 = [41.6 41.6 41.6 41.6 41.6 41.6 41.6 41.6 41.6 41.6 41.6 41.6 41.6 41.6 41.6 -inf -inf -inf ];
        % Cluster 2 Power [dB]
         pdb2 = [-inf -inf -inf -inf -1.8 -2.8 -3.5 -4.4 -5.3 -7.4 -7.0 -10.3 -10.4 -13.8 -15.7 -19.9 -inf -inf ];
        % AoA AoA [?]
         AoA_C2 = [-inf -inf -inf -inf 180.4 180.4 180.4 180.4 180.4 180.4 180.4 180.4 180.4 180.4 180.4 180.4  -inf -inf];
        % AS AS [?]
         AS_Rx_C2 = [-inf -inf -inf -inf 55.0 55.0 55.0 55.0 55.0 55.0 55.0 55.0 55.0 55.0 55.0 55.0  -inf -inf]; 
        % AoD AoD [?]
         AoD_C2= [-inf -inf -inf -inf 183.7 183.7 183.7 183.7 183.7 183.7 183.7 183.7 183.7 183.7 183.7 183.7  -inf -inf];
        % AS AS [?]
         AS_Tx_C2 = [-inf -inf -inf -inf 55.2 55.2 55.2 55.2 55.2 55.2 55.2 55.2 55.2 55.2 55.2 55.2  -inf -inf];
        % Cluster 3 Power [dB] 
        pdb3 = [-inf -inf -inf -inf -inf -inf -inf -inf -5.7 -6.7 -10.4 -9.6 -14.1 -12.7 -18.5 -inf -inf -inf ];
        % AoA AoA [?]
         AoA_C3 = [-inf -inf -inf -inf -inf -inf -inf -inf 74.7 74.7 74.7 74.7 74.7 74.7 74.7  -inf -inf -inf];
        % AS AS [?]
         AS_Rx_C3 = [-inf -inf -inf -inf -inf -inf -inf -inf 42.0 42.0 42.0 42.0 42.0 42.0 42.0 -inf -inf -inf ];
        % AoD AoD [?] 
        AoD_C3  = [-inf -inf -inf -inf -inf -inf -inf -inf 153.0 153.0 153.0 153.0 153.0 153.0 153.0  -inf -inf -inf];
        % AS AS [?] 
        AS_Tx_C3 = [-inf -inf -inf -inf -inf -inf -inf -inf 47.4 47.4 47.4 47.4 47.4 47.4 47.4  -inf -inf -inf];
        % Appendix C ? Model F (2/2) 
        % Cluster 4 Power [dB]
         pdb4 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -8.8 -13.3 -18.7 -inf -inf -inf ];
        % AoA AoA [?]
         AoA_C4 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 251.5 251.5 251.5 -inf -inf -inf  ];
        % AS AS [?]
         AS_Rx_C4 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 28.6 28.6 28.6 -inf -inf -inf ];
        % AoD AoD [?]
         AoD_C4 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 112.5 112.5 112.5 -inf -inf -inf ];
        % AS AS [?]
         AS_Tx_C4 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 27.2 27.2 27.2 -inf -inf -inf ]; 
        % Cluster 5 Power [dB]
         pdb5 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -12.9 -14.2 -inf -inf ]; 
        % AoA AoA [?]
         AoA_C5 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 68.5 68.5 -inf -inf]; 
        % AS AS [?]
         AS_Rx_C5 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 30.7 30.7  -inf -inf];
        % AoD AoD [?]
         AoD_C5 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 291.0 291.0 -inf -inf]; 
        % AS AS [?]
         AS_Tx_C5 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 33.0 33.0 -inf -inf]; 
        % Cluster 6 Power [dB]
         pdb6 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -16.3 -21.2]; 
        % AoA AoA [?]
         AoA_C6 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 246.2 246.2]; 
        % AS AS [?]
         AS_Rx_C6 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 38.2 38.2]; 
        % AoD AoD [?]
         AoD_C6 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 62.3 62.3]; 
        % AS AS 
        AS_Tx_C6 = [-inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf -inf 38.0 38.0];

        pdb = [pdb1; pdb2; pdb3;pdb4; pdb5;pdb6];
        AoA = [AoA_C1; AoA_C2;AoA_C3;AoA_C4;AoA_C5;AoA_C6];
        AS_Rx = [AS_Rx_C1; AS_Rx_C2;AS_Rx_C3;AS_Rx_C4;AS_Rx_C5;AS_Rx_C6];
        AoD  = [AoD_C1; AoD_C2;AoD_C3;AoD_C4;AoD_C5;AoD_C6];
        AS_Tx = [AS_Tx_C1; AS_Tx_C2;AS_Tx_C3;AS_Tx_C4;AS_Tx_C5;AS_Tx_C6];
        
        
        dBP = 30;
        K = 10^(-inf/10);  %NLOS
        if (d<dBP)
            K=10^(6/10); %LOS
        end
    otherwise 
        disp('Unknown type')
        
end 




end