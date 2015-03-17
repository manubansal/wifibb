
function [stats, pkt_samples, fine_cfo_freq_off_khz] = wifi_fine_cfo_correction(copt, opt, stats, pkt_samples, cplen)
  sample_duration_sec = opt.sample_duration_sec;
  stf_len = opt.stf_len;
  ltf_len = opt.ltf_len;
  sig_len = opt.sig_len;
  ltf_shift_len = opt.ltf_shift_len;

  cp_len_ltf = copt.cp_len_s_ltf;
  cp_skip_ltf  = copt.cp_skip_ltf;

  fft_size  = opt.fft_size ;
  pkt_length_samples = length(pkt_samples);
  ltf_samples = pkt_samples(stf_len+1:stf_len+ltf_len);
  %------ ltf based cfo estimation and correction -------
  if (opt.FINE_CFO_CORRECTION)
    display('ltf based cfo estimation and correction');
    ltf1_s = ltf_samples(cp_len_ltf+1+cp_skip_ltf:cp_len_ltf+cp_skip_ltf+fft_size);
    ltf2_s = ltf_samples(cp_len_ltf+1+cp_skip_ltf+fft_size:cp_len_ltf+cp_skip_ltf+2*fft_size);

    angle_corr = angle(sum(conj(ltf1_s) .* ltf2_s));
    freq_off_khz = (angle_corr/(2*pi*ltf_shift_len*sample_duration_sec))/1000;
    %pause

    stats.fine_cfo_angle_corr(end+1,:) = angle_corr;
    stats.fine_cfo_freq_off_khz(end+1,:) = freq_off_khz;
    fine_cfo_freq_off_khz = freq_off_khz;


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

    %t_secs = [0:(stf_len+ltf_len-1)]*sample_duration_sec - 160 * sample_duration_sec;			%correction time-coeffs for stf, ltf parts
    t_secs = [0:(stf_len+ltf_len-1)]*sample_duration_sec - opt.stf_len * sample_duration_sec;			%correction time-coeffs for stf, ltf parts
    %NOTE: I'm not sure if I am replacing 160 by the right mnemonic quantity. --MB, 08/24/14

    t_secs = [t_secs mod([0:((pkt_length_samples - stf_len - ltf_len)-1)],opt.sym_len_s)*sample_duration_sec];	%correction time-coeffs for data symbols appended
    cfo_corr = exp(-2*pi*i*freq_off_hz*t_secs);


    %cfo correction
    pkt_samples = pkt_samples .* cfo_corr;

    %cfo corrected ltf and data portions
    ltf_samples = pkt_samples(stf_len+1:stf_len+ltf_len);
    sig_samples = pkt_samples(stf_len+ltf_len+1:stf_len+ltf_len+sig_len);
    data_samples = pkt_samples(stf_len+ltf_len+sig_len+1:end);

    %%%%%%%%%%%%%%%%%%%%%%%
    ltf_samples = pkt_samples(stf_len+1:stf_len+ltf_len);
    ltf1_t = ltf_samples(1+cp_len_ltf+cp_skip_ltf : cp_len_ltf+cp_skip_ltf+fft_size);
    ltf2_t = ltf_samples(1+cp_len_ltf+cp_skip_ltf+fft_size : cp_len_ltf+cp_skip_ltf+2*fft_size);
    display('ltfs in time domain after all cfo correction');
    if (opt.printVars_chEsts)
	  display('the two ltfs: ')
	  [ [1:fft_size]' fix(opt.ti_factor_after_cfo * [ ltf1_t.' ltf2_t.'])]
	  %pause
    end
    %%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%
    plcp_samples = sig_samples;
    display('plcp signal field in time domain after all cfo correction');
    if (opt.printVars_cfoCorrectedPlcp)
	  [ [1:length(plcp_samples)]' fix(opt.ti_factor_after_cfo * plcp_samples.')]
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
end
