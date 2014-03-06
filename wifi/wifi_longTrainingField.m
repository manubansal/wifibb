
function ltf_sync_total = wifi_longTrainingField()
  ltf_sync_freq_domain = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0, ...
			  1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1]';
  ltf_sync_freq_domain = [ zeros(6,1); ltf_sync_freq_domain; zeros(5,1)];

  ltf_sync_time_oneperiod = (ifft(ifftshift(ltf_sync_freq_domain)));

  window_func = [0.5 ones(1,159) 0.5]';
  %add cp and double the length, and multiply by the window function
  ltf_sync_total = window_func.*[ltf_sync_time_oneperiod( (33):64); 
				  ltf_sync_time_oneperiod; 
				  ltf_sync_time_oneperiod;
				  ltf_sync_time_oneperiod(1)];
                            
end
