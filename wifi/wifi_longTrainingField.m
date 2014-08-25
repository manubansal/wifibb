
function ltf_sync_total = wifi_longTrainingField(cplen)
  opt = {};
  opt = wifi_common_parameters(opt, cplen);
  cp_len_ltf = opt.cp_len_s_ltf;
  ltf_len = opt.ltf_len;


  ltf_sync_freq_domain = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0, ...
			  1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1]';
  ltf_sync_freq_domain = [ zeros(6,1); ltf_sync_freq_domain; zeros(5,1)];

  ltf_sync_time_oneperiod = (ifft(ifftshift(ltf_sync_freq_domain)));

  window_func = [0.5 ones(1,ltf_len-1) 0.5]';
  %add cp and double the length, and multiply by the window function

  total_cp_len = cp_len_ltf * 2;
  n_reps_needed = ceil(total_cp_len/length(ltf_sync_time_oneperiod));
  reps = repmat(ltf_sync_time_oneperiod, n_reps_needed, 1);
  cp_ltf = reps(end-total_cp_len+1:end);

  %ltf_sync_total = window_func.*[ltf_sync_time_oneperiod( (33):64); 
  ltf_sync_total = window_func.*[cp_ltf;
				  ltf_sync_time_oneperiod; 
				  ltf_sync_time_oneperiod;
				  ltf_sync_time_oneperiod(1)];
                            
end
