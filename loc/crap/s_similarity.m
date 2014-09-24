
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
