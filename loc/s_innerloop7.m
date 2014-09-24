function [theta, PMU_trans_7, Pos_new] = s_innerloop7(INPDATA, OFF, signature_start_point)
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

  %OFF = [OFF12 OFF13 OFF14 OFF15 OFF16 OFF17 OFF18];

  %INIT
  m=1; % how many packet
  AOA_NUM=50; % for each packet, how many samples will be used

  srt_point=signature_start_point;
  end_point=AOA_NUM + signature_start_point - 1;

  h=3;
  p=8; %number of antennas
  w=exp(1i*2*pi/p);
  mode=-3;

  %select signature data
  a = srt_point;
  b = end_point;

  D1 = Node2_Radio1_RxData(a:b);
  D2 = Node2_Radio2_RxData(a:b);
  D3 = Node2_Radio3_RxData(a:b);
  D4 = Node2_Radio4_RxData(a:b);

  D5 = Node1_Radio1_RxData(a:b);
  D6 = Node1_Radio2_RxData(a:b);
  D7 = Node1_Radio3_RxData(a:b);
  D8 = Node1_Radio4_RxData(a:b);

  % multiply phase offsets
  %D1 = D1;
  D2 = D2 .*exp(1i*OFF12);
  D3 = D3 .*exp(1i*OFF13);
  D4 = D4 .*exp(1i*OFF14);

  D5 = D5 .*exp(1i*OFF15);
  D6 = D6 .*exp(1i*OFF16);
  D7 = D7 .*exp(1i*OFF17);
  D8 = D8 .*exp(1i*OFF18);

  C=[D1;D2;D3;D4;D5;D6;D7;D8];

  C_8171=[D1;D2;D3;D4;D5;D6;D7];
  C_8172=[D2;D3;D4;D5;D6;D7;D8];
  
  Rxx=zeros(8,8);
  
  Rxx_8171=zeros(7,7);
  Rxx_8172=zeros(7,7);
      
  %compute the correlation matrix
  for j=1:AOA_NUM
      Rxx =  Rxx + C(:,j) *  (C(:,j))';
      
      Rxx_8171 =  Rxx_8171 + C_8171(:,j) *  (C_8171(:,j))';
      Rxx_8172 =  Rxx_8172 + C_8172(:,j) *  (C_8172(:,j))';
  end
      
  %Rxx averaging
  Rave_8171= Rxx_8171/AOA_NUM;
  Rave_8172= Rxx_8172/AOA_NUM;
  Rave_817_ave=(Rave_8171 + Rave_8172) * 0.5 ;
  
  %Rxx eigen decomposition
  [EV_817_ave,V_817_ave]=eig(Rave_817_ave);
  Evalue_817_ave = diag(V_817_ave);
  
  %eigenvalue sorting
  [Y_817_ave,INDEX_817_ave] = sort (diag (V_817_ave));

  %noise subspace construction
  EN_817_ave=EV_817_ave(:,INDEX_817_ave(1:M_817 -D_817));

  % steering vector array for 8 antennas in a line and SSP 7x1
  theta=(-pi/2-pi/360):pi/360:pi/2;
  a817= [ones(1,length(theta)); exp(1i .*(1 .* pi .* sin(theta))); exp(1i .*(2 .* pi .* sin(theta))) ;exp(1i .*(3 .* pi .* sin(theta))) ; exp(1i .*(4 .* pi .* sin(theta))); exp(1i .*(5 .* pi .* sin(theta))) ;exp(1i .*(6 .* pi .* sin(theta)))];

  %MUSIC spectrum computation using steering vector polar sweep
  MU_817_ave=a817' * EN_817_ave * (EN_817_ave)' * a817;
  MUD_817_ave = diag(MU_817_ave);
  PMU_817_ave=1.00 ./abs(MUD_817_ave);
  
  [MA2_817,MP2_817]= max(PMU_817_ave);
  
  EValue=EN_817_ave * (EN_817_ave)';
  
  [Max_new2, Pos_new2]=findpeaks(log(PMU_817_ave/MA2_817));
  Pos_new2=(Pos_new2 -180)/2;
  [Max_new, Pos_new]=findpeaks(log(PMU_817_ave/MA2_817));
  Pos_new=(Pos_new -180)/2;
  
  PMU_trans_7 =(PMU_817_ave/MA2_817).';
end
