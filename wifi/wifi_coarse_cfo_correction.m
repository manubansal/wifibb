
function [stats, pkt_samples, coarse_cfo_freq_off_khz] = wifi_coarse_cfo_correction(opt, stats, pkt_samples, corrvec, pkt_start_point)
  stf_shift_len = opt.stf_shift_len;
  sample_duration_sec = opt.sample_duration_sec;
  stf_len = opt.stf_len;
  ltf_len = opt.ltf_len;
  sig_len = opt.sig_len;
  pkt_length_samples = length(pkt_samples);
  stf_samples = pkt_samples(1:stf_len);
  %------ stf based cfo estimation and correction ------
  if (opt.COARSE_CFO_CORRECTION)
    display('stf based cfo estimation and correction');

    %a more accurate estimate but possibly missing multiples of 2*pi
    %%%%%angle_corr = angle(data.corrvec(data.pkt_start_point));		%radians
    angle_corr = angle(corrvec(pkt_start_point));		%radians
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

end

