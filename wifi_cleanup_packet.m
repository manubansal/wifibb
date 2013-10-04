
%----------------------------------------------------------------------------------------------------------------------------
function [stats data] = wifi_cleanup_packet(data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  data.cleanupDone = 0;

  noise_win_len = opt.noise_win_len;
  noise_fft_size = opt.noise_fft_size;
  stf_len = opt.stf_len;
  ltf_len = opt.ltf_len;
  sig_len = opt.sig_len;
  stf_shift_len = opt.stf_shift_len;
  ltf_shift_len = opt.ltf_shift_len;
  sample_duration_sec = opt.sample_duration_sec;

  sym_len_s  = opt.sym_len_s ;
  cp_len_s  = opt.cp_len_s ;
  fft_size  = opt.fft_size ;
  cp_skip  = opt.cp_skip ;


  rx_data_syms = [];
  data.rx_data_syms = rx_data_syms; 

  if (nargin < 3)
    opt.COARSE_CFO_CORRECTION = true;
    opt.FINE_CFO_CORRECTION = true;
    opt.PILOT_PHASE_TRACKING = true;
    opt.PILOT_SAMPLING_DELAY_CORRECTION = true;		%this is really referring to sampling delay 
    							%introduced due to sampling frequency offset
    opt.GENERATE_ONE_TIME_PLOTS = true;
    opt.GENERATE_PER_PACKET_PLOTS = false;
  end

  %verify availability of enough noise samples for the noise window to be analyzed
  %if (data.pkt_start_point < 1+noise_win_len)
  %  display('not enough pre-noise samples for this packet')
  %  data.pkt_start_point = -2;
  %  return
  %end

  %verify validity of pkt detect point - corr value must drop on either side (it should be a peak)
  %%%data.pkt_start_point-10
  %%%data.pkt_start_point-1
  left_10_c = data.abscorrvec(data.pkt_start_point-10:data.pkt_start_point-1);
  right_10_c = data.abscorrvec(data.pkt_start_point+1:data.pkt_start_point+10);
  peak_c = data.abscorrvec(data.pkt_start_point);

  if ([left_10_c right_10_c] > peak_c)
    display('packet correlation peak not well-detected')
    return
  end

  %verify we have the whole packet in sample stream
  %if (length(data.samples) < data.pkt_start_point + opt.pkt_length_samples - 1)
  if (length(data.samples) < data.pkt_start_point + opt.ns_ofdm_phy_preamble_signal - 1)
    %display('sample stream does not contain the entire packet');
    display('sample stream does not contain even enough samples for preamble and signal field');
    return
  end

  %if (isfield(opt,'pkt_length_samples'))
  %  pkt_length_samples = opt.pkt_length_samples;
  %else
  %  pkt_length_samples = opt.max_pkt_length_samples;
  %end
  %This is so that we don't need to know the packet length for this module.
  pkt_length_samples = min(opt.max_pkt_length_samples, length(data.samples) - data.pkt_start_point + 1);

  if (length(data.samples) < data.pkt_start_point + pkt_length_samples - 1)
    %display('sample stream does not contain the entire packet');
    display('sample stream does not contain enough samples for processing');
    return
  end

  %pkt_samples = data.samples(data.pkt_start_point:data.pkt_start_point+opt.pkt_length_samples-1);
  pkt_samples = data.samples(data.pkt_start_point:data.pkt_start_point+pkt_length_samples-1);
  stf_samples = pkt_samples(1:stf_len);
  ltf_samples = pkt_samples(stf_len+1:stf_len+ltf_len);
  sig_samples = pkt_samples((stf_len+ltf_len+1):(stf_len+ltf_len+sig_len));
  data_samples = pkt_samples(stf_len+ltf_len+sig_len+1:end);

  %verify availability of enough noise samples for the noise window to be analyzed
  if (data.pkt_start_point < 1+noise_win_len)
    display('not enough pre-noise samples for this packet, using as many as available')
  %  data.pkt_start_point = -2;
  %  return
    noise_samples = data.samples(1:data.pkt_start_point-1);
  else
    noise_samples = data.samples(data.pkt_start_point-noise_win_len:data.pkt_start_point-1);
  end

  %display('power and snr values before any processing:');
  %display('(these are computed based on silent period noise power and packet samples in time domain)');

  idle_noise_power = util_power(noise_samples);
  stf_power = util_power(stf_samples);
  ltf_power = util_power(ltf_samples);
  sig_power = util_power(sig_samples);
  %%%%data_power = util_power(data_samples);			%estimate from the whole data part
  data_power = util_power(data_samples(1:80));		%estimate only from the first data symbol
  pkt_power = util_power(pkt_samples);

  snr_lin = stf_power/idle_noise_power;
  snr_db = 10*log10(snr_lin);

  stats.idle_noise_power(end+1,:) = idle_noise_power;
  stats.stf_power(end+1,:) = stf_power;
  stats.ltf_power(end+1,:) = ltf_power;
  stats.sig_power(end+1,:) = sig_power;
  stats.data_power(end+1,:) = data_power;
  stats.pkt_power(end+1,:) = pkt_power;

  stats.snr_lin(end+1,:) = snr_lin;
  stats.snr_db(end+1,:) = snr_db;



  %------ stf based cfo estimation and correction ------
  if (opt.COARSE_CFO_CORRECTION)
    display('stf based cfo estimation and correction');

    %a more accurate estimate but possibly missing multiples of 2*pi
    angle_corr = angle(data.corrvec(data.pkt_start_point));		%radians
    %freq_off_khz = (angle_corr/(pi*stf_len*sample_duration_sec))/1000
    freq_off_khz = (angle_corr/(2*pi*stf_shift_len*sample_duration_sec))/1000;

    %for detecting multiples of 2*pi in case the offset is really high
    stf_period = 16;
    stf_9th_period = stf_samples(8*stf_period+1:9*stf_period);
    stf_10th_period = stf_samples(9*stf_period+1:end);
    angle_corr_short = angle(sum(conj(stf_9th_period) .* stf_10th_period));
    angle_corr_pred_from_short = angle_corr_short * 5;
    %freq_off_khz = (angle_corr/(pi*stf_len*sample_duration_sec))/1000
    freq_off_khz_short = (angle_corr_short/(2*pi*stf_period*sample_duration_sec))/1000;

    if (abs(angle_corr_pred_from_short - angle_corr) > pi) 
      display('CFO detection algorithm maybe be missing multiples of pi.');
      display('Inspect the values above and press any key to proceed.');
      pause
    end

    stats.coarse_cfo_angle_corr(end+1,:) = angle_corr;
    stats.coarse_cfo_freq_off_khz(end+1,:) = freq_off_khz;
    coarse_cfo_freq_off_khz = freq_off_khz;

    %version 1: where stf starts at time t = 0
    %%freq_off_hz = freq_off_khz * 1000;
    %%%t_secs = [0:(opt.pkt_length_samples-1)]*sample_duration_sec;
    %%t_secs = [0:(pkt_length_samples-1)]*sample_duration_sec;
    %%cfo_corr = exp(-2*pi*i*freq_off_hz*t_secs);

    %%%version 2: where ltf starts at time t = 0; this matches how we do it on TI
    %%freq_off_hz = freq_off_khz * 1000;
    %%%t_secs = [0:(opt.pkt_length_samples-1)]*sample_duration_sec;
    %%t_secs = [0:(pkt_length_samples-1)]*sample_duration_sec - 160 * sample_duration_sec;
    %%cfo_corr = exp(-2*pi*i*freq_off_hz*t_secs);

    %version 3: where each data symbol is also modeled as starting at time t = 0; this matches how we do it on TI
    %ltf 160 samples are in series, as also on TI.
    freq_off_hz = freq_off_khz * 1000;
    t_secs = [0:(stf_len+ltf_len-1)]*sample_duration_sec - 160 * sample_duration_sec;			%correction time-coeffs for stf, ltf parts
    t_secs = [t_secs mod([0:((pkt_length_samples - stf_len - ltf_len)-1)],80)*sample_duration_sec];	%correction time-coeffs for data symbols appended
    cfo_corr = exp(-2*pi*i*freq_off_hz*t_secs);


    %%%%%%%%%%%%%%%%%%%%%%%
    ltf_samples = pkt_samples(stf_len+1:stf_len+ltf_len);
    ltf1_t = ltf_samples(33:96);
    ltf2_t = ltf_samples(97:160);
    display('ltfs in time domain before any cfo');
    if (opt.printVars_chEsts)
	  display('the two ltfs: ')
	  [ [1:64]' fix(opt.ti_factor * [ ltf1_t.' ltf2_t.'])]
	  %pause
    end
    %%%%%%%%%%%%%%%%%%%%%%%

    %cfo correction
    pkt_samples = pkt_samples .* cfo_corr;

    %cfo corrected ltf and data portions
    ltf_samples = pkt_samples(stf_len+1:stf_len+ltf_len);
    sig_samples = pkt_samples(stf_len+ltf_len+1:stf_len+ltf_len+sig_len);
    data_samples = pkt_samples(stf_len+ltf_len+sig_len+1:end);
  else
    display('stf based cfo estimation and correction is disabled');
  end


  %------ ltf based cfo estimation and correction -------
  if (opt.FINE_CFO_CORRECTION)
    display('ltf based cfo estimation and correction');
    ltf1_s = ltf_samples(16+1+cp_skip:16+cp_skip+fft_size);
    ltf2_s = ltf_samples(16+1+cp_skip+fft_size:16+cp_skip+2*fft_size);

    angle_corr = angle(sum(conj(ltf1_s) .* ltf2_s));
    freq_off_khz = (angle_corr/(2*pi*ltf_shift_len*sample_duration_sec))/1000;
    %pause

    stats.fine_cfo_angle_corr(end+1,:) = angle_corr;
    stats.fine_cfo_freq_off_khz(end+1,:) = freq_off_khz;
    fine_cfo_freq_off_khz = freq_off_khz;

    net_cfo_freq_off_khz = coarse_cfo_freq_off_khz + fine_cfo_freq_off_khz
    pause

    %version 1, where stf starts at t = 0
    %%freq_off_hz = freq_off_khz * 1000;
    %%%t_secs = [0:(opt.pkt_length_samples-1)]*sample_duration_sec;
    %%t_secs = [0:(pkt_length_samples-1)]*sample_duration_sec;
    %%cfo_corr = exp(-2*pi*i*freq_off_hz*t_secs);

    %%%version 2: where ltf starts at time t = 0; this matches how we do it on TI
    %%freq_off_hz = freq_off_khz * 1000;
    %%%t_secs = [0:(opt.pkt_length_samples-1)]*sample_duration_sec;
    %%t_secs = [0:(pkt_length_samples-1)]*sample_duration_sec - 160 * sample_duration_sec;
    %%cfo_corr = exp(-2*pi*i*freq_off_hz*t_secs);

    %version 3: where each data symbol is also modeled as starting at time t = 0; this matches how we do it on TI
    %ltf 160 samples are in series, as also on TI.
    freq_off_hz = freq_off_khz * 1000;
    t_secs = [0:(stf_len+ltf_len-1)]*sample_duration_sec - 160 * sample_duration_sec;			%correction time-coeffs for stf, ltf parts
    t_secs = [t_secs mod([0:((pkt_length_samples - stf_len - ltf_len)-1)],80)*sample_duration_sec];	%correction time-coeffs for data symbols appended
    cfo_corr = exp(-2*pi*i*freq_off_hz*t_secs);


    %cfo correction
    pkt_samples = pkt_samples .* cfo_corr;

    %cfo corrected ltf and data portions
    ltf_samples = pkt_samples(stf_len+1:stf_len+ltf_len);
    sig_samples = pkt_samples(stf_len+ltf_len+1:stf_len+ltf_len+sig_len);
    data_samples = pkt_samples(stf_len+ltf_len+sig_len+1:end);

    %%%%%%%%%%%%%%%%%%%%%%%
    ltf_samples = pkt_samples(stf_len+1:stf_len+ltf_len);
    ltf1_t = ltf_samples(33:96);
    ltf2_t = ltf_samples(97:160);
    display('ltfs in time domain after all cfo correction');
    if (opt.printVars_chEsts)
	  display('the two ltfs: ')
	  [ [1:64]' fix(opt.ti_factor_after_cfo * [ ltf1_t.' ltf2_t.'])]
	  %pause
    end
    %%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%
    plcp_samples = sig_samples;
    display('plcp signal field in time domain after all cfo correction');
    if (opt.printVars_cfoCorrectedPlcp)
	  [ [1:80]' fix(opt.ti_factor_after_cfo * plcp_samples.')]
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
	    pause
	  end
    end
    %%%%%%%%%%%%%%%%%%%%%%%


  else
    display('ltf based cfo estimation and correcion is disabled')
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % estimating noise PSD after rx decimation
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Note: the following samples still suffer cfo,
  %thus, this PSD is not accurate.

  %%%%%n_noise_symbols = length(noise_samples)/noise_fft_size;
  %%%%%noise_symbols = reshape(noise_samples,noise_fft_size,n_noise_symbols);
  %%%%%%since noise is not white anymore due to frequency-selective filters, we 
  %%%%%%want to have the true PSD computed using fft
  %%%%%size(noise_symbols)
  %%%%%noise_syms_f = fftshift(fft(noise_symbols));
  %%%%%size(noise_syms_f)
  %%%%%noise_syms_f_power = noise_syms_f .* conj(noise_syms_f);
  %%%%%format long;
  %%%%%noise_syms_f_power_av = sum(noise_syms_f_power,2)/n_noise_symbols
  %%%%%pause

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
  ltf1_s = ltf_samples(16+1+cp_skip:16+cp_skip+fft_size);
  ltf2_s = ltf_samples(16+1+cp_skip+fft_size:16+cp_skip+2*fft_size);
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

  data.uu_ltf1 = uu_ltf1;
  data.uu_ltf2 = uu_ltf2;
  %data.ltf_sync_freq_domain = ltf_sync_freq_domain;
  data.ch = ch;

  %[uu_ltf1 uu_ltf2 abs(uu_ltf1) abs(uu_ltf2) angle(uu_ltf1) angle(uu_ltf2)]
  %pause

  chi = 1./ch;
  ch_abs_db = 10*log10(abs(ch));

  data.sig_samples = sig_samples;
  data.data_samples = data_samples;
  data.chi = chi;

  display('channel gains, channel gain magnitudes (dB):');
  [ch ch_abs_db]

  if (opt.GENERATE_PER_PACKET_PLOTS)
    figure
    hold on
    plot(1:64, angle(uu_ltf1),'b-.');
    plot(1:64, angle(uu_ltf2),'r-.');
  end
  %pause

  data.cleanupDone = 1;

  if (opt.GENERATE_PER_PACKET_PLOTS)
    figure

    subplot(6,1,1)
    hold on
    plot(1:64, abs(ltf1_f),'g-.');
    plot(1:64, abs(ltf2_f),'b-.');
    plot(1:64, abs(ltf_f_av),'r-.');
    title('|.| of ltf symbols in frequency domain after cfo correction, red: mean')
    grid on
    %title('|.|')

    subplot(6,1,2)
    hold on
    plot(1:64, real(ltf1_f),'g-.');
    plot(1:64, real(ltf2_f),'b-.');
    plot(1:64, real(ltf_f_av),'r-.');
    title('real(.)')
    grid on

    subplot(6,1,3)
    hold on
    plot(1:64, imag(ltf1_f),'g-.');
    plot(1:64, imag(ltf2_f),'b-.');
    plot(1:64, imag(ltf_f_av),'r-.');
    title('imag(.)')
    grid on

    subplot(6,1,4)
    plot(1:64, abs(ch),'g-.');
    title('|.| of channel, linear');
    grid on

    subplot(6,1,4)
    plot(1:64, abs(ch),'g-.');
    title('|.| of channel, linear');
    grid on

    subplot(6,1,5)
    plot(1:64, ch_abs_db,'b-.');
    title('|.| of channel, dB');
    grid on

    subplot(6,1,6)
    plot(1:64, angle(ch),'b-.');
    title('angle(.) of channel');
    grid on
  end
end
