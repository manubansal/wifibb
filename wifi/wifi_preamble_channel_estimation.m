
function [stats, uu_ltf1, uu_ltf2, ltf1_f, ltf2_f, ltf_f_av, ch, ch_abs_db, chi] = wifi_preamble_channel_estimation(opt, stats, pkt_samples, cplen)
  copt = wifi_common_parameters({}, cplen);
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
  ltf_sync_freq_domain = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0, ...
			  1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1]';
  ltf_sync_freq_domain = [ zeros(6,1); ltf_sync_freq_domain; zeros(5,1)];

  %ltf_sync_time_oneperiod = (ifft(ifftshift(ltf_sync_freq_domain)))

%  window_func = [0.5 ones(1,159) 0.5]';
%  %add cp and double the length, and multiply by the window function
%  ltf_sync_total = window_func.*[ltf_sync_time_oneperiod( (33):64); 
%				  ltf_sync_time_oneperiod; 
%				  ltf_sync_time_oneperiod;
%				  ltf_sync_time_oneperiod(1)]
  ltf1_s = ltf_samples(cp_len+1+cp_skip:cp_len+cp_skip+fft_size);
  ltf2_s = ltf_samples(cp_len+1+cp_skip+fft_size:cp_len+cp_skip+2*fft_size);
  ltf1_f = fftshift(fft(ltf1_s));
  ltf2_f = fftshift(fft(ltf2_s));

  if (opt.printVars_chEsts)
	  display('the two ltfs in frequency domain: ')
	  [ [1:64]' fix(opt.ti_factor * [ ltf1_f.' ltf2_f.'])]
	  pause
  end

  %%%%%%%%%%%%% begin algo 1 %%%%%%%%%%%%%%%
  %complex channel gain
  ltf_f_av = (ltf1_f+ltf2_f)/2;			%NOTE: This may be a bad idea in the presence of sampling frequency offset.
  						%SFO should firt be corrected, then the ltf symbols should be averaged.

  %display('ltf1, ltf2, ltf_average:');
  %[ltf1_f.' ltf2_f.' ltf_f_av.']

  ch = (ltf_f_av.') .* ltf_sync_freq_domain;		%multiplication is used instead of division because
  						%the reference ltf symbol sequence (freq domain) contains
						%zeroes. since the loaded symbols have magnitude 1, multiplication
						%is equivalent to division for rest of the subcarriers.
  %%%%%%%%%%%%% finish algo 1 %%%%%%%%%%%%%%%

  %add to statistics
  stats.all_ltf1_64(end+1:end+64) = ltf1_f;
  stats.all_ltf2_64(end+1:end+64) = ltf2_f;
  stats.all_ltf_av_64(end+1:end+64) = ltf_f_av;
  stats.all_channel_64(end+1:end+64) = ch;

  if (opt.printVars_chEsts)
	  [ [1:64]' fix(opt.ti_factor * ch)]
	  nsubc = 64
	  psubc_idx = (nsubc/2)+[(1+[-21 -7 7 21])];					%regular order (dc in middle)
	  dsubc_idx = (nsubc/2)+[(1+[-26:-22 -20:-8 -6:-1]) (1+[1:6 8:20 22:26])];	%regular order (dc in middle)
	  ch_data = [[1:48]' fix(opt.ti_factor * ch(dsubc_idx))]
	  ch_pilot = [[1:4]' fix(opt.ti_factor * ch(psubc_idx))]
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


  h = wifi_time_domain_channel_impulse_response(ltf_sync_freq_domain, ltf_samples, cplen);
end

function h = wifi_time_domain_channel_impulse_response(ltf_sync_freq_domain, ltf_samples, cplen)
  ltf_sync_freq_domain = ltf_sync_freq_domain.';
  %ltf_x = ifft(ltf_sync_freq_domain);
  ltf_x = ifft(ifftshift(ltf_sync_freq_domain));
  ltf_x = [ltf_x(end-2*cplen+1:end) ltf_x ltf_x];
  ltf_y = ltf_samples;
  taplength = 64;
  %taplength = 52;
  %taplength = 40;
  h = time_domain_channel_impulse_response(ltf_x, ltf_y, taplength);
  stem(abs(h))
  pause
end
