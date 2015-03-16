

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
