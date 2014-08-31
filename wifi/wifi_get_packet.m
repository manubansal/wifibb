
%------------------------------------------------------------------------------------
function [stats data pkt_samples] = wifi_get_packet(data, opt, stats)
%------------------------------------------------------------------------------------
  pkt_samples = [];
  data.cleanupDone = 0;

  noise_win_len = opt.noise_win_len;
  noise_fft_size = opt.noise_fft_size;
  stf_len = opt.stf_len;
  ltf_len = opt.ltf_len;
  sig_len = opt.sig_len;

  sym_len_s  = opt.sym_len_s ;
  cp_len_s  = opt.cp_len_s ;
  fft_size  = opt.fft_size ;


  rx_data_syms = [];
  data.rx_data_syms = rx_data_syms; 

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

  %verify we have the whole packet in sample stream
  %if (length(data.samples) < data.pkt_start_point + pkt_length_samples - 1)
  %if (length(data.samples) < data.pkt_start_point + pkt_length_samples - 1)
  %  %display('sample stream does not contain the entire packet');
  %  display('ERROR: sample stream does not contain enough samples for processing');
  %  pause
  %  return
  %end
  if (length(data.samples) < data.pkt_start_point + 480)
    display('WARNING: sample stream does not contain enough samples for data part to have at least one ofdm symbol');
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
  %%%%data_power = util_power(data_samples(1:80));		%estimate only from the first data symbol
  data_power = util_power(data_samples(1:min(length(data_samples),80)));%estimate only from the first data symbol
  pkt_power = util_power(pkt_samples);

  idle_noise_power_db = db(idle_noise_power)
  stf_power_db = db(stf_power)
  ltf_power_db = db(ltf_power)
  sig_power_db = db(sig_power)
  data_power_db = db(data_power)
  pkt_power_db = db(pkt_power)

  snr_lin = stf_power/idle_noise_power;
  snr_db = db(snr_lin);

  stats.idle_noise_power(end+1,:) = idle_noise_power;
  stats.stf_power(end+1,:) = stf_power;
  stats.ltf_power(end+1,:) = ltf_power;
  stats.sig_power(end+1,:) = sig_power;
  stats.data_power(end+1,:) = data_power;
  stats.pkt_power(end+1,:) = pkt_power;

  stats.snr_lin(end+1,:) = snr_lin;
  stats.snr_db(end+1,:) = snr_db;

end

function v = db(lin)
  v = 10*log10(lin);
end
