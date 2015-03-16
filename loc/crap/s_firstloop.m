function [theta, PMU_trans_7] = s_firstloop(INPDATA, OFF, off_index)
  PMU_trans_7 = {};

  Node2_Radio1_RxData = INPDATA(1,:);
  Node2_Radio2_RxData = INPDATA(2,:);
  Node2_Radio3_RxData = INPDATA(3,:);
  Node2_Radio4_RxData = INPDATA(4,:);
  Node1_Radio1_RxData = INPDATA(5,:);
  Node1_Radio2_RxData = INPDATA(6,:);
  Node1_Radio3_RxData = INPDATA(7,:);
  Node1_Radio4_RxData = INPDATA(8,:);

  OFF12 = OFF(1);
  OFF13 = OFF(2);
  OFF14 = OFF(3);
  OFF15 = OFF(4);
  OFF16 = OFF(5);
  OFF17 = OFF(6);
  OFF18 = OFF(7);

  D_common=3;
  M_817=7;
  D_817=D_common;
  M_816=6;
  D_816=D_common;
  M_815=5;
  D_815=D_common;
  M_818=8;
  D_818=D_common;
  D_M8=1;


  %FIRST_INIT

  OFF = [OFF12 OFF13 OFF14 OFF15 OFF16 OFF17 OFF18];

  %FIRST_INIT
  m=1; % how many packet
  AOA_NUM=50; % for each packet, how many samples will be used
  L=0;
  WIN_SIZE=800;
  WIN_OFFSET=10 + 800 * off_index;

  %%%%%%%%%% MB %%%%%%%%%%%%%%%
  % MORE INIT STUFF
  %%%%%%%%%% MB %%%%%%%%%%%%%%%

  max_plot=zeros(m,1);

  P= zeros(m,3); % P= zeros(m+1,3);

  Rxx=cell(m,1);

  Rxx_8171=cell(m,1);
  Rxx_8172=cell(m,1);

  Rxx_8161=cell(m,1);
  Rxx_8162=cell(m,1);
  Rxx_8163=cell(m,1);

  Rxx_8151=cell(m,1);
  Rxx_8152=cell(m,1);
  Rxx_8153=cell(m,1);
  Rxx_8154=cell(m,1);

  Rave_8151=cell(m,1);
  Rave_8152=cell(m,1);
  Rave_8153=cell(m,1);
  Rave_8154=cell(m,1);
  Rave_815_ave = cell(m,1);
  EV_815_ave=cell(m,1);
  V_815_ave=cell(m,1);
  Evalue_815_ave=cell(m,1);
  Y_815_ave=cell(m,1);
  INDEX_815_ave=cell(m,1);
  EN_815_ave=cell(m,1);
  MU_815_ave=cell(m,1);
  MUD_815_ave=cell(m,1);
  PMU_815_ave=cell(m,1);
  MA2_815=cell(m,1);
  MP2_815=cell(m,1);
  MT2_815=0;
  MV2_815=0;

  Rave_8171=cell(m,1);
  Rave_8172=cell(m,1);

  Rave_817_ave = cell(m,1);
  EV_817_ave=cell(m,1);
  V_817_ave=cell(m,1);
  Evalue_817_ave=cell(m,1);
  Y_817_ave=cell(m,1);
  INDEX_817_ave=cell(m,1);
  EN_817_ave=cell(m,1);
  MU_817_ave=cell(m,1);
  MUD_817_ave=cell(m,1);
  PMU_817_ave=cell(m,1);
  MA2_817=cell(m,1);
  MP2_817=cell(m,1);
  MT2_817=0;
  MV2_817=0;

  %EVector1=cell(m,1);
  %RXX1=cell(m,1);
  %EValue1=cell(m,1);
  %
  %ES_817_ave=cell(m,1);
  %EValue11=cell(m,1);

  %FIRST_PREP_DATA
  theta=(-pi/2-pi/360):pi/360:pi/2;
  n_n=0;

  % steering vector for 8 antennas in a line and SSP 7x1:
  a817= [ones(1,length(theta)); exp(1i .*(1 .* pi .* sin(theta))); exp(1i .*(2 .* pi .* sin(theta))) ;exp(1i .*(3 .* pi .* sin(theta))) ; exp(1i .*(4 .* pi .* sin(theta))); exp(1i .*(5 .* pi .* sin(theta))) ;exp(1i .*(6 .* pi .* sin(theta)))];

  % steering vector for 8 antennas in a line and SSP 5x1:
  a815= [ones(1,length(theta)); exp(1i .*(1 .* pi .* sin(theta))); exp(1i .*(2 .* pi .* sin(theta))) ;exp(1i .*(3 .* pi .* sin(theta))) ; exp(1i .*(4 .* pi .* sin(theta)))];

  % steering vector for 7 antennas in a circle (without any spatial smoothing)
  a_c= [exp(1i .*(1 .* pi .* sin(theta + 1*pi/2 ))); exp(1i .*(1 .* pi .* sin(theta+ 3*pi/4 ))); exp(1i .*(1 .* pi .* sin(theta+ 8*pi/8 )));exp(1i .*(1 .* pi .* sin(theta+ 10*pi/8 ))); exp(1i .*(1 .* pi .* sin(theta+ 12*pi/8 ))); exp(1i .*(1 .* pi .* sin(theta+ 14*pi/8 )));exp(1i .*(1 .* pi .* sin(theta+ 16*pi/8 ))); exp(1i .*(1 .* pi .* sin(theta+ 18*pi/8 ))); ];

  h=3;
  p=8; %number of antennas
  w=exp(1i*2*pi/p);
  mode=-3;

  J_trans= diag([diag(1/(sqrt(p)* 1i^mode * besselj(mode,pi))); diag(1/(sqrt(p)* 1i^(mode+1) * besselj(mode+1,pi)));  diag(1/(sqrt(p)* 1i^(mode+2) * besselj(mode+2,pi)));  diag(1/(sqrt(p)* 1i^(mode+3) * besselj(mode+3,pi)));  diag(1/(sqrt(p)* 1i^(mode+4) * besselj(mode+4,pi)));  diag(1/(sqrt(p)* 1i^(mode+5) * besselj(mode+5,pi)));  diag(1/(sqrt(p)* 1i^(mode+6) * besselj(mode+6,pi))); ]);

  F_trans= [1 w^(-h) w^(-2*h) w^(-3*h) w^(-4*h) w^(-5*h) w^(-6*h) w^(-7*h) ;1 w^(-(h-1)) w^(-2*(h-1)) w^(-3*(h-1)) w^(-4*(h-1)) w^(-5*(h-1)) w^(-6*(h-2)) w^(-7*(h-2));1 w^(-(h-2)) w^(-2*(h-2)) w^(-3*(h-2)) w^(-4*(h-2)) w^(-5*(h-2)) w^(-6*(h-2)) w^(-7*(h-2)) ; 1 w^(-(h-3)) w^(-2*(h-3)) w^(-3*(h-3)) w^(-4*(h-3)) w^(-5*(h-3)) w^(-6*(h-3)) w^(-7*(h-3)); 1 w^(-(h-4)) w^(-2*(h-4)) w^(-3*(h-4)) w^(-4*(h-4)) w^(-5*(h-4)) w^(-6*(h-4)) w^(-7*(h-4)); 1 w^(-(h-5)) w^(-2*(h-5)) w^(-3*(h-5)) w^(-4*(h-5)) w^(-5*(h-5)) w^(-6*(h-5)) w^(-7*(h-5)); 1 w^(-(h-6)) w^(-2*(h-6)) w^(-3*(h-6)) w^(-4*(h-6)) w^(-5*(h-6)) w^(-6*(h-6)) w^(-7*(h-6))];
  a_trans= J_trans* F_trans * a_c;
  size(a_trans);


  %%%%%%%%%% MB %%%%%%%%%%%
  % The NodeX_RadioY_RxData fields are loaded from trace files,
  % It seems like they are row vectors when loaded.
  %%%%%%%%%% MB %%%%%%%%%%%

  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
  % prepare test data - start
  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
  D1 = Node2_Radio1_RxData.';
  D2 = (Node2_Radio2_RxData.') .*exp(1i*OFF12);  % apply phase offset to it.
  D3 = (Node2_Radio3_RxData.') .*exp(1i*OFF13);
  D4 = (Node2_Radio4_RxData.') .*exp(1i*OFF14);

  D5 = (Node1_Radio1_RxData.') .*exp(1i*OFF15);
  D6_N = (Node1_Radio2_RxData.') .*exp(1i*OFF16);
  D7_N = (Node1_Radio3_RxData.') .*exp(1i*OFF17);
  D8_N = (Node1_Radio4_RxData.') .*exp(1i*OFF18);


  if (L>=1) % handle the shift of L
      
      D6=D6_N(1+L:1:end);
      D7=D7_N(1+L:1:end);
      D8=D8_N(1+L:1:end);
      
      D6(end:1:end+L)=0;
      D7(end:1:end+L)=0;
      D8(end:1:end+L)=0;
      
  elseif (L==0)
      
      D6=D6_N;
      D7=D7_N;
      D8=D8_N;
      
  else
      
      D6=zeros(size(D6_N));
      D7=zeros(size(D7_N));
      D8=zeros(size(D8_N));
      D6(-L+1:1:end)=D6_N(1:1:end+L);
      D7(-L+1:1:end)=D7_N(1:1:end+L);
      D8(-L+1:1:end)=D8_N(1:1:end+L);
      
      D6(1:1:-L)=0;
      D7(1:1:-L)=0;
      D8(1:1:-L)=0;
  end

  C=[D1 D2 D3 D4 D5 D6 D7 D8];

  C_8171=[D1 D2 D3 D4 D5 D6 D7];
  C_8172=[D2 D3 D4 D5 D6 D7 D8];

  C_8161=[D1 D2 D3 D4 D5 D6];
  C_8162=[D2 D3 D4 D5 D6 D7];
  C_8163=[D3 D4 D5 D6 D7 D8];

  C_8151=[D1 D2 D3 D4 D5];
  C_8152=[D2 D3 D4 D5 D6];
  C_8153=[D3 D4 D5 D6 D7];
  C_8154=[D4 D5 D6 D7 D8];

  C = C.';

  C_8171=C_8171.';
  C_8172=C_8172.';
  C_8161=C_8161.';
  C_8162=C_8162.';
  C_8163=C_8163.';
  C_8151=C_8151.';
  C_8152=C_8152.';
  C_8153=C_8153.';
  C_8154=C_8154.';
  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
  % prepare test data - end
  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%

  %FIRST_II
  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
  % more init stuff
  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
  CP=cell(m,1); % jiexiong, here I want to plot 40 lines on one graph.

  CP_8171=cell(m,1);
  CP_8172=cell(m,1);

  CP_8161=cell(m,1);
  CP_8162=cell(m,1);
  CP_8163=cell(m,1);

  CP_8151=cell(m,1);
  CP_8152=cell(m,1);
  CP_8153=cell(m,1);
  CP_8154=cell(m,1);

  CP_s=cell(m,1);

  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
  % some parameter array
  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
  P(1,3)=AOA_NUM;
  P(1,1)=1 + WIN_OFFSET;
  P(1,2)=AOA_NUM + WIN_OFFSET;

  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
  % more parameter initialization stuff
  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
  % initiate from the second
  for j=1:1:floor(m/(WIN_SIZE/200))
      
      P(j+1,3)= AOA_NUM; %number of samples in each packet
      P(j+1,1)=(j)*WIN_SIZE+1 + WIN_OFFSET;
      P(j+1,2)=(j)*WIN_SIZE +AOA_NUM +WIN_OFFSET;
      
      
      CP{j} =zeros(P(j,3),8);  % 8 antenna
      CP_8171{j}= zeros(P(j,3),7); % 8x1; ssp 7x1
      CP_8172{j}= zeros(P(j,3),7);
      
      CP_8161{j}= zeros(P(j,3),6);
      CP_8162{j}= zeros(P(j,3),6); % 8x1: ssp 6x1
      CP_8163{j}= zeros(P(j,3),6);
      
      CP_8151{j}= zeros(P(j,3),5);
      CP_8152{j}= zeros(P(j,3),5); % 8x1: ssp 5x1
      CP_8153{j}= zeros(P(j,3),5);
      CP_8154{j}= zeros(P(j,3),5);
      
      CP_s{j}= zeros(P(j,3),4);
  end
  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
  %for loop on j = 1:floor(m/(WIN_SIZE/200))
  %not sure what this is for
  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%

  %FIRST_FOR_LOOP
  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
  % in the following loop, n seems to
  % be a scaled packet index. the variable
  % n isn't being used directly, so it is
  % simply serving to iterate through packets.
  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
  for n = 0:WIN_SIZE:(m-1)*WIN_SIZE
      
      %for n = 0:200:numSamples-1
      
      n_n= n_n+1;
      
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      % Select relevant data from C's to CP's
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      if (n_n<=m)  % update with all data only when n<=m as i only plot m lines.
	  
	  
	  CP{n_n} = C(:,(P(n_n,1):1: P(n_n,2)));
	  CP_8171{n_n} = C_8171(:,(P(n_n,1):1: P(n_n,2)));
	  CP_8172{n_n} = C_8172(:,(P(n_n,1):1: P(n_n,2)));
	  
	  CP_8161{n_n} = C_8161(:,(P(n_n,1):1: P(n_n,2)));
	  CP_8162{n_n} = C_8162(:,(P(n_n,1):1: P(n_n,2)));
	  CP_8163{n_n} = C_8163(:,(P(n_n,1):1: P(n_n,2)));
	  
	  CP_8151{n_n} = C_8151(:,(P(n_n,1):1: P(n_n,2)));
	  CP_8152{n_n} = C_8152(:,(P(n_n,1):1: P(n_n,2)));
	  CP_8153{n_n} = C_8153(:,(P(n_n,1):1: P(n_n,2)));
	  CP_8154{n_n} = C_8154(:,(P(n_n,1):1: P(n_n,2)));
	  
	  
      end
      
      Rxx{n_n}=zeros(8,8);
      
      Rxx_8171{n_n}=zeros(7,7);
      Rxx_8172{n_n}=zeros(7,7);
      
      Rxx_8161{n_n}=zeros(6,6);
      Rxx_8162{n_n}=zeros(6,6);
      Rxx_8163{n_n}=zeros(6,6);
      
      Rxx_8151{n_n}=zeros(5,5);
      Rxx_8152{n_n}=zeros(5,5);
      Rxx_8153{n_n}=zeros(5,5);
      Rxx_8154{n_n}=zeros(5,5);
      
      
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      % Computation starts -- compute on CP's
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      % so j is running from 1 to AOA_NUM,
      % that is, the number of samples that
      % will be used.
      %
      % This loop seems to be computing the
      % energies of AOA_NUM vectors where each
      % vector is made up of corresponding samples
      % received on different antennas, so, CP is
      % probably organized as:
      % CP = [
      % ax1_t0, ax1_t1, .... ax1_tAOA_NUM;
      % ax2_t0, ax2_t1, .... ax2_tAOA_NUM;
      % ...
      % ax8_t0, ax8_t1, .... ax8_tAOA_NUM;
      % ]
      % Then, in each iteration of this loop,
      % energy of a column vector in this matrix
      % is being computed and added to Rxx entry.
      % Each of those column vectors actually
      % corresponds to a single observation of
      % phase-array reception.
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      
      for j=1:1:P(n_n,3)
	  
	  Rxx{n_n} =  Rxx{n_n} + CP{n_n}(:,j) *  (CP{n_n}(:,j))';
	  
	  Rxx_8171{n_n} =  Rxx_8171{n_n} + CP_8171{n_n}(:,j) *  (CP_8171{n_n}(:,j))';
	  Rxx_8172{n_n} =  Rxx_8172{n_n} + CP_8172{n_n}(:,j) *  (CP_8172{n_n}(:,j))';
	  
	  Rxx_8161{n_n} =  Rxx_8161{n_n} + CP_8161{n_n}(:,j) *  (CP_8161{n_n}(:,j))';
	  Rxx_8162{n_n} =  Rxx_8162{n_n} + CP_8162{n_n}(:,j) *  (CP_8162{n_n}(:,j))';
	  Rxx_8163{n_n} =  Rxx_8163{n_n} + CP_8163{n_n}(:,j) *  (CP_8163{n_n}(:,j))';
	  Rxx_8151{n_n} =  Rxx_8151{n_n} + CP_8151{n_n}(:,j) *  (CP_8151{n_n}(:,j))';
	  Rxx_8152{n_n} =  Rxx_8152{n_n} + CP_8152{n_n}(:,j) *  (CP_8152{n_n}(:,j))';
	  Rxx_8153{n_n} =  Rxx_8153{n_n} + CP_8153{n_n}(:,j) *  (CP_8153{n_n}(:,j))';
	  Rxx_8154{n_n} =  Rxx_8154{n_n} + CP_8154{n_n}(:,j) *  (CP_8154{n_n}(:,j))';
	  
      end
      
      
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      % The following is probably the MUSIC algorithm
      %%%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      % MUSIC START
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      % Rave: average phase-array received vector energy
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      Rave_8171{n_n}= Rxx_8171{n_n}/P(n_n,3);
      Rave_8172{n_n}= Rxx_8172{n_n}/P(n_n,3);
      Rave_817_ave{n_n}=(Rave_8171{n_n} + Rave_8172{n_n}) * 0.5 ;
      
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      % eigenvalue decomposition of an energy matrix?
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      [EV_817_ave{n_n},V_817_ave{n_n}]=eig(Rave_817_ave{n_n});
      Evalue_817_ave{n_n} = diag(V_817_ave{n_n});
      
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      % MUSIC END
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      
      
      
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      % same set of computations for the 5-antenna system?
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      % MUSIC START
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      Rave_8151{n_n}= Rxx_8151{n_n}/P(n_n,3);
      Rave_8152{n_n}= Rxx_8152{n_n}/P(n_n,3);
      Rave_8153{n_n}= Rxx_8153{n_n}/P(n_n,3);
      Rave_8154{n_n}= Rxx_8154{n_n}/P(n_n,3);
      
      Rave_815_ave{n_n}=(Rave_8151{n_n} + Rave_8152{n_n}+ Rave_8153{n_n}+ Rave_8154{n_n} ) * 0.25 ;
      [EV_815_ave{n_n},V_815_ave{n_n}]=eig(Rave_815_ave{n_n});
      EV_815_ave{n_n};
      V_815_ave{n_n};
      Evalue_815_ave{n_n} = diag(V_815_ave{n_n});
      Evalue_815_ave{n_n};
      Evalue_815_ave{n_n}(5,1);
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      % MUSIC END
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      
      
      
      [Y_817_ave{n_n},INDEX_817_ave{n_n}] = sort (diag (V_817_ave{n_n}));
      EN_817_ave{n_n}=EV_817_ave{n_n}(:,INDEX_817_ave{n_n}(1:M_817 -D_817));
      MU_817_ave{n_n}=a817' * EN_817_ave{n_n} * (EN_817_ave{n_n})' * a817;
      MUD_817_ave{n_n} = diag(MU_817_ave{n_n});
      PMU_817_ave{n_n}=1.00 ./abs(MUD_817_ave{n_n});
      
      [MA2_817{n_n},MP2_817{n_n}]= max(PMU_817_ave{n_n});
      % MP2_4{n_n}=(MP2_4{n_n}-180.5)/2;
      MT2_817=MT2_817+MP2_817{n_n};
      if MV2_817 <= MA2_817{n_n}  % for normilizing the plot
	  MV2_817 =MA2_817{n_n};
      end
      
      %EValue1=EN_817_ave{n_n} * (EN_817_ave{n_n})';
      EValue=EN_817_ave{n_n} * (EN_817_ave{n_n})';
      
      [Y_815_ave{n_n},INDEX_815_ave{n_n}] = sort (diag (V_815_ave{n_n}));
      EN_815_ave{n_n}=EV_815_ave{n_n}(:,INDEX_815_ave{n_n}(1:M_815 -D_815));
      MU_815_ave{n_n}=a815' * EN_815_ave{n_n} * (EN_815_ave{n_n})' * a815;
      MUD_815_ave{n_n} = diag(MU_815_ave{n_n});
      PMU_815_ave{n_n}=1.00 ./abs(MUD_815_ave{n_n});
      
      [MA2_815{n_n},MP2_815{n_n}]= max(PMU_815_ave{n_n});
      % MP2_4{n_n}=(MP2_4{n_n}-180.5)/2;
      MT2_815=MT2_815+MP2_815{n_n};
      if MV2_815 <= MA2_815{n_n}  % for normilizing the plot
	  MV2_815 =MA2_815{n_n};
      end
      
      
      %%%%%%%%%%%% commentented by MB %%%%%%%%%
      %[Max, Pos]=peak(log(PMU_817_ave{n_n}/MA2_817{n_n}), 2, -0.1); % calibrated with the maximum of each round
      %size(Max);
      %size(Pos);
      %%%%%%%%%%%% commentented by MB %%%%%%%%%
      
      %[Max_new1, Pos_new1]=findpeaks(log(PMU_817_ave{n_n}/MA2_817{n_n}));
      %Pos_new1=(Pos_new1 -180)/2;
      [Max_new, Pos_new]=findpeaks(log(PMU_817_ave{n_n}/MA2_817{n_n}));
      Pos_new=(Pos_new -180)/2;
      
      %%if (off_index==2 && file_num==28 && random_num==1)
      %if (off_index==2 && file_num==5 && random_num==1)
      %    
      %    PMU_trans_7=(PMU_817_ave{n_n}/MA2_817{n_n}).';
      %    polar(theta,PMU_trans_7);
      %    
      %    hold on
      %    
      %end
      %%}

      PMU_trans_7{n_n} =(PMU_817_ave{n_n}/MA2_817{n_n}).';
      
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      % Computation ends
      %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
      
      
  end
  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
  %end of n=0:WIN_SIZE:(m-1)*WIN_SIZE loop
  %so the iteration count of this loop is
  %the same as ni=0:1:(m-1), that is, m times,
  %one iteration per packet. so it seems like
  %this loop is stepping through the samples of
  %captured packets, where each packet occupies
  %WIN_SIZE samples.
  %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
end
