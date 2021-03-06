function [] = securearray(INPDATA, pkt_start_points)

% This version generates AOA spectra for comparison

% Read in one file and then compare packet


%%%%%%%%%% MB: INIT STUFF %%%%%%%%%%%

mm=5;
cell_matrix1=cell(mm,1);
cell_matrix2=cell(mm,1);

figure;

%%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
% this outer loop runs the whole thing
% with different phase perturbations
%%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
%for random_num=1:1:3
for random_num=1:1:1
    
    
    start_point=0;
    move_step=0.02;
    ending_point=1;
    angle_th=5;
    num_total=30;
    %test_step=1+ (ending_point - start_point)/move_step; %0.4 to 0.96 with 0.05 as a step
    test_step=51;
    test_step_count=0;
    group_num=1;
    client_rej_rate=zeros(test_step,36);
    attacker_rej_rate=zeros(test_step,36);
    num_pos=30;
    num_group=6*6;
    
    similarity_matrix1=zeros(num_pos,num_group);
    similarity_matrix2=zeros(num_pos,num_group);
    
    cell_matrix1{random_num}=zeros(num_pos,num_group);
    cell_matrix2{random_num}=zeros(num_pos,num_group);
    
    OFF = offsets(random_num);
    
    %for file_num=1:1:5

    %load the recorded files
    %if (nargin < 1)
    %  INPDATA=load_trace_data(file_num);
    %end

    %%%% CLIENT FIRST TX %%%%
    start_point_1 = pkt_start_points(1) + 160 + 10;
    %[theta, PMU_trans_7, Pos_new] = s_innerloop(INPDATA, OFF, start_point_1);
    %polar(theta,PMU_trans_7{1}, 'b');
    [theta, PMU_trans_7, Pos_new] = s_innerloop7(INPDATA, OFF, start_point_1);
    polar(theta,PMU_trans_7, 'b');
    hold on

    %%%% ATTACKER %%%%
    start_point_2 = pkt_start_points(2) + 160 + 10;
    %[theta, PMU_trans_7, Pos_new] = s_innerloop(INPDATA, OFF, start_point_2);
    %polar(theta,PMU_trans_7{1}, 'r');
    [theta, PMU_trans_7, Pos_new] = s_innerloop7(INPDATA, OFF, start_point_2);
    polar(theta,PMU_trans_7, 'r');
    hold on

    %end
            
    %SIMILARITY
            
        
    hold off

    if nargin < 1
    ev=['clear load/MOBICOM2013_alternative_' int2str(jie_gap) '_' jie_distance '_'  sprintf('%03d', file_num) '.mat'];
    eval(ev);

    end %end of file_num=1:30 for loop
    
    %similarity_matrix1
    %similarity_matrix2
    
    cell_matrix1{random_num} = similarity_matrix1;
    cell_matrix2{random_num} = similarity_matrix2;
    
    
    %cell_matrix2{random_num}
    
    
    for sim_th=start_point:move_step:ending_point
        
        test_step_count=test_step_count+1;
        
        client_count=0;
        client_rej_count=0;
        attacker_count=0;
        attacker_rej_count=0;
        
        for file_num=1:1:num_total
            
            client_count=client_count+1;
            attacker_count=attacker_count+1;
            %count the number of acception
            if similarity_matrix1(file_num,group_num) <= sim_th %wrongly rejected legitimate clients
                
                client_rej_count=client_rej_count+1;
                
            end
            
            if similarity_matrix2(file_num,group_num) <= sim_th%wrongly rejected legitimate clients
                
                attacker_rej_count=attacker_rej_count+1;
                
            end
            
        end
        client_rej_rate(test_step_count,1)=client_rej_count/client_count;
        attacker_rej_rate(test_step_count,1)=attacker_rej_count/attacker_count;
        
    end
    client_rej_count
    attacker_rej_count
    
    client_rej_rate(:,1);
    attacker_rej_rate(:,1);
    
end
end

%STATS

function OFF = offsets(random_num)
    switch random_num
        case 1 % this is the correct phase offset
            
            cali12=0.71;
            cali13=0.51;
            cali14=5.2;
            cali15=1.60;
            cali16=3.05;
            cali17=1.55;
            cali18=5.60;
            CO='magenta';
            
        case 2 % this is radom 1
            
            cali12=3.97;
            cali13=0.23;
            cali14=0.54;
            cali15=5.80;
            cali16=0.96;
            cali17=6.13;
            cali18=3.83;
            CO='blue';
            
        case 3 % this is random 2
            
            cali12=2.71;
            cali13=4.05;
            cali14=0.29;
            cali15=4.60;
            cali16=6.05;
            cali17=4.95;
            cali18=2.60;
            CO='black';
    end

        cable12=0.02;
        cable13=0.03;
        cable14=0.06;
        cable15=-0.015;
        cable16=-0.07;
        cable17=0.06;
        cable18=-0.025;
        
        OFF12=cali12 +cable12;
        OFF13=cali13 +cable13;
        OFF14=cali14 +cable14;
        OFF15=cali15 +cable15;
        OFF16=cali16 +cable16;
        OFF17=cali17 +cable17;
        OFF18=cali18 +cable18;

  OFF = [OFF12 OFF13 OFF14 OFF15 OFF16 OFF17 OFF18];
end

function INPDATA = load_trace_data(file_num)
  jie_gap= 20000;
  jie_distance='5cm';

  ev=['load traces/MOBICOM2013_alternative_' int2str(jie_gap) '_' jie_distance '_'  sprintf('%03d', file_num) '.mat'];
  eval(ev);

  INPDATA=[...
      Node2_Radio1_RxData;...
      Node2_Radio2_RxData;...
      Node2_Radio3_RxData;...
      Node2_Radio4_RxData;...
      Node1_Radio1_RxData;...
      Node1_Radio2_RxData;...
      Node1_Radio3_RxData;...
      Node1_Radio4_RxData;...
      ];
end
