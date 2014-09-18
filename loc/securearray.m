function [] = Mobicom13_securearray()

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
for random_num=1:1:3
    
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
    
    
    for off_index=1:1:2
        
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
        
        jie_gap= 20000;
        jie_distance='5cm';
        
        
        %%%%%%%%%% MB %%%%%%%%%%%%%%%
        % LOAD UP TRACES
        %%%%%%%%%% MB %%%%%%%%%%%%%%%
        
        
        %load the recorded files
        
        %for file_num=1:1:30
        for file_num=1:1:5
            
            if file_num>=1 && file_num<=9
                
                ev=['load MOBICOM2013_alternative_' int2str(jie_gap) '_' jie_distance '_00'  int2str(file_num) '.mat'];
                eval(ev);
                
            elseif file_num>=10
                
                ev=['load MOBICOM2013_alternative_' int2str(jie_gap) '_' jie_distance '_0'  int2str(file_num) '.mat'];
                eval(ev);
                
            end
            
            %%%%%%%%%% MB %%%%%%%%%%%%%%%
            % MORE PARAMS
            %%%%%%%%%% MB %%%%%%%%%%%%%%%
            
            m=1; % how many packet
            AOA_NUM=50; % for each packet, how many samples will be used
            L=0;
            WIN_SIZE=800;
            WIN_OFFSET=10;
            
	    FIRST_INIT
            

	    FIRST_PREP_DATA
            
	    FIRST_II
            
	    FIRST_FOR_LOOP
            
            
            %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
            % init stuff again
            %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
            m=1; % how many packet
            AOA_NUM=50; % for each packet, how many samples will be used
            L=0; % shiftif nn
            WIN_SIZE=800;
            WIN_OFFSET=10 + 800* off_index; % mofify here to use different packet
            
            SECOND_INIT

	    SECOND_PREP_DATA
            
	    SECOND_II
            
	    SECOND_FOR_LOOP

            
            
            if file_num>=1 && file_num<=9
                
                ev=['clear MOBICOM2013_alternative_' int2str(jie_gap) '_' jie_distance '_00'  int2str(file_num) '.mat'];
                eval(ev);
                
            elseif file_num>=10
                
                ev=['clear MOBICOM2013_alternative_' int2str(jie_gap) '_' jie_distance '_0'  int2str(file_num) '.mat'];
                eval(ev);
                
            end
            
            
            %jie implement the comparison algoritm here
            
            %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
            %start of similarity computation
            %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%

            [size_r1,size_c1]=size(Pos_new1);
            [size_r2,size_c2]=size(Pos_new2);
            
            
            similarity_count=0;
            nor_factor1=0;
            nor_factor2=0;
            
            
            for j=1:1:size_r1
                
                for i=1:1:size_r2
                    
                    if Pos_new1(j)>=-80 && Pos_new2(i)>=-80 && abs(Pos_new1(j)-Pos_new2(i))<=angle_th
                        
                        similarity_count= similarity_count+ (exp(Max_new1(j)) * exp(Max_new2(i)));
                        
                    end
                    
                end
                
            end
            
            for j=1:1:size_r1
                
                if Pos_new1(j)>=-80
                    nor_factor1=nor_factor1+ 0.5 * ((exp(Max_new1(j)))^2);
                end
                
            end
            
            for i=1:1:size_r2
                
                
                if Pos_new2(i)>=-80
                    nor_factor2=nor_factor2+ 0.5 * ((exp(Max_new2(i)))^2);
                end
            end
            
            
            nor_factor=nor_factor1 + nor_factor2;
            
            similarity_index = similarity_count/nor_factor;
            similarity_index
            
            %sim_th=0.8;
            
            if off_index==2 %client and client
                
                similarity_matrix1(file_num,group_num)=similarity_index;
                
            elseif off_index==1
                
                similarity_matrix2(file_num,group_num)=similarity_index;
                
                %count the number of rejection
            end
            %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
            %end of similarity computation
            %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
            
        end
        %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
        %end of file_num=1:30 for loop
        %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
        
    end
    %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
    %end of off_index=1:2 for loop
    %%%%%%%%%%%%% MB %%%%%%%%%%%%%%%%%
    
    
    %similarity_matrix1
    %similarity_matrix2
    
    cell_matrix1{random_num} = similarity_matrix1;
    cell_matrix2{random_num} = similarity_matrix2;
    
    
    cell_matrix2{random_num}
    
    
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



%%%%%%%%%% MB %%%%%%%%%%%%%%%
% rest seems like stats stuff
%%%%%%%%%% MB %%%%%%%%%%%%%%%


opt1_min=min(min(cell_matrix1{1},cell_matrix1{2}),cell_matrix1{3});
opt1_ave=0.33* (cell_matrix1{1}+cell_matrix1{2}+cell_matrix1{3});

opt2_min=min(min(cell_matrix2{1},cell_matrix2{2}),cell_matrix2{3});
opt2_ave=0.33* (cell_matrix2{1}+cell_matrix2{2} + cell_matrix2{3});

test_step_count=0;
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
        if opt1_ave(file_num,group_num) <= sim_th %wrongly rejected legitimate clients
            
            client_rej_count=client_rej_count+1;
            
        end
        
        if opt2_ave(file_num,group_num) <= sim_th%wrongly rejected legitimate clients
            
            attacker_rej_count=attacker_rej_count+1;
            
        end
        
    end
    client_rej_rate(test_step_count,1)=client_rej_count/client_count;
    attacker_rej_rate(test_step_count,1)=attacker_rej_count/attacker_count;
    
end

cell_matrix1{1}
cell_matrix1{2}
cell_matrix1{3}

cell_matrix2{1}
cell_matrix2{2}
cell_matrix2{3}


test_step_count=0;
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
        if opt1_min(file_num,group_num) <= sim_th %wrongly rejected legitimate clients
            
            client_rej_count=client_rej_count+1;
            
        end
        
        if opt2_min(file_num,group_num) <= sim_th%wrongly rejected legitimate clients
            
            attacker_rej_count=attacker_rej_count+1;
            
        end
        
    end
    client_rej_rate(test_step_count,1)=client_rej_count/client_count;
    attacker_rej_rate(test_step_count,1)=attacker_rej_count/attacker_count;
    
end

similarity_matrix1
similarity_matrix2
