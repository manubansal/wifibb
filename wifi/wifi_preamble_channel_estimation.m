
function [stats, uu_ltf1, uu_ltf2, ltf1_f, ltf2_f, ltf_f_av, ch, ch_abs_db, chi] = wifi_preamble_channel_estimation(copt, opt, stats, pkt_samples, cplen)
  cp_len = copt.cp_len_s_ltf;
  cp_skip  = copt.cp_skip_ltf;

  stf_len = opt.stf_len;
  ltf_len = opt.ltf_len;
  %sig_len = opt.sig_len;

  %sym_len_s  = opt.sym_len_s ;
  %cp_len_s  = opt.cp_len_s ;
  fft_size  = opt.fft_size ;
  %pkt_length_samples = length(pkt_samples);
  ltf_samples = pkt_samples(stf_len+1:stf_len+ltf_len);
  %------- channel estimation and correction ----
  ltf_sync_freq_domain = copt.ltf_sync_freq_domain;
  
  %[1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0, ...
%			  1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1]';
%  ltf_sync_freq_domain = [ zeros(6,1); ltf_sync_freq_domain; zeros(5,1)];

  %ltf_sync_time_oneperiod = (sqrt(length(ltf_sync_freq_domain))*ifft(ifftshift(ltf_sync_freq_domain)))

%  window_func = [0.5 ones(1,159) 0.5]';
%  %add cp and double the length, and multiply by the window function
%  ltf_sync_total = window_func.*[ltf_sync_time_oneperiod( (33):64); 
%				  ltf_sync_time_oneperiod; 
%				  ltf_sync_time_oneperiod;
%				  ltf_sync_time_oneperiod(1)]
  ltf1_s = ltf_samples(cp_len+cp_skip+1:cp_len+cp_skip+fft_size);
  ltf2_s = ltf_samples(cp_len+cp_skip+fft_size+1:cp_len+cp_skip+2*fft_size);
  ltf1_f = fftshift(1/sqrt(length(ltf1_s))*fft(ltf1_s));
  ltf2_f = fftshift(1/sqrt(length(ltf2_s))*fft(ltf2_s));

  if (opt.printVars_chEsts)
	  display('the two ltfs in frequency domain: ')
	  [ [1:fft_size]' fix(opt.ti_factor * [ ltf1_f.' ltf2_f.'])]
	  pause
  end

%   %%%%%%%%%%%%% begin algo 1 %%%%%%%%%%%%%%%
%   %complex channel gain
%   ltf_f_av = (ltf1_f+ltf2_f)/2;			%NOTE: This may be a bad idea in the presence of sampling frequency offset.
%   						%SFO should firt be corrected, then the ltf symbols should be averaged.
% 
%   %display('ltf1, ltf2, ltf_average:');
%   %[ltf1_f.' ltf2_f.' ltf_f_av.']
% 
%   ch = (ltf_f_av.') .* ltf_sync_freq_domain;		%multiplication is used instead of division because
%   						%the reference ltf symbol sequence (freq domain) contains
% 						%zeroes. since the loaded symbols have magnitude 1, multiplication
% 						%is equivalent to division for rest of the subcarriers.
%   %%%%%%%%%%%%% finish algo 1 %%%%%%%%%%%%%%%
  
  %%%%%%%%%%%%% begin algo 2 %%%%%%%%%%%%%%%
  %complex channel gain
  ch1 = (ltf1_f.') .* ltf_sync_freq_domain;
  ch2 = (ltf2_f.') .* ltf_sync_freq_domain;
    % multiplication is used instead of division because the 
    % reference ltf symbol sequence (freq domain) contains zeroes. 
    % since the loaded symbols have magnitude 1, multiplication
	% is equivalent to division for rest of the subcarriers.
  
  ch = (ch1 + ch2)/2;
%   for i_ch = 1 : length(ch1)
%       window_by_2 = min(min(i_ch-1, length(ch1)-i_ch), 2);
%       ch(i_ch) = mean([ch1(i_ch-window_by_2 : i_ch+window_by_2) ; 
%           ch2(i_ch-window_by_2 : i_ch+window_by_2)]);
%   end

%  save('./debug/ch_0', 'ch');
%  ch = getfield(load('ch_0.mat', 'ch'), 'ch');

  ltf_f_av = ch.*ltf_sync_freq_domain;
  ltf_f_av = ltf_f_av.';

  %%%%%%%%%%%%% finish algo 2 %%%%%%%%%%%%%%%

  %%%%%%%%%%%%% begin algo 3 (td ch est) %%%%%%%%%%%%%%%

  [h, ltf_x] = wifi_time_domain_channel_impulse_response(ltf_sync_freq_domain, ltf_samples, cplen);
  
  %%%%%%%%%%%%% finish algo 3 %%%%%%%%%%%%%%%

  %add to statistics
  stats.all_ltf1_64(end+1:end+fft_size) = ltf1_f;
  stats.all_ltf2_64(end+1:end+fft_size) = ltf2_f;
  stats.all_ltf_av_64(end+1:end+fft_size) = ltf_f_av;
  stats.all_channel_64(end+1:end+fft_size) = ch;
  stats.td_channel = h;

  if (opt.printVars_chEsts)
	  [ [1:copt.nsubc]' fix(opt.ti_factor * ch)]
	  nsubc = copt.nsubc
	  psubc_idx = copt.psubc_idx;	%regular order (dc in middle)
	  dsubc_idx = copt.dsubc_idx;	%regular order (dc in middle)
	  ch_data = [[1:copt.ndatasubc]' fix(opt.ti_factor * ch(dsubc_idx))]
	  ch_pilot = [[1:copt.npsubc]' fix(opt.ti_factor * ch(psubc_idx))]
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
	  pause
	  end
  end

  %%%%%%%%%%%%% begin algo 2 %%%%%%%%%%%%%%%
  %scalar magnitude only
  %ltf_f_av = abs(ltf1_f) + abs(ltf2_f);
  %ch = (ltf_f_av)/2;
  %%%%%%%%%%%%% finish algo 2 %%%%%%%%%%%%%%%
  
  uu_ltf1 = (ltf1_f.') .* ltf_sync_freq_domain;		%multiplication is used instead of division because
  uu_ltf2 = (ltf2_f.') .* ltf_sync_freq_domain;		%multiplication is used instead of division because

  %%%%data.uu_ltf1 = uu_ltf1;
  %%%%data.uu_ltf2 = uu_ltf2;
  %data.ltf_sync_freq_domain = ltf_sync_freq_domain;

  %[uu_ltf1 uu_ltf2 abs(uu_ltf1) abs(uu_ltf2) angle(uu_ltf1) angle(uu_ltf2)]
  %pause

  chi = 1./ch;
  ch_abs_db = 10*log10(abs(ch));


  %display('channel gains, channel gain magnitudes (dB):');
  %[ch ch_abs_db]




  td_data_samples = [0 0].';
  confStr = 'jj';
  tx_params.dumpVars_stfLtf = false;
  %--------------------------------------------------------------------------
  td_pkt_samples = util_prepend_preamble(opt, td_data_samples, confStr, tx_params, cplen);
  %--------------------------------------------------------------------------
  
end

