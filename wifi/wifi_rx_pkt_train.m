function rx_pkts = wifi_rx_pkt_train(samples, confStr, cplen)
  rx_pkts = {}

  %scale = sqrt(2);
  scale = 'kk';
  %mod = 'jj';

  [opt, stats] = wifi_rx_parameters('1','54M','null',cplen);

  if length(samples) == 0
    samples = util_loadBinaryFilePart(opt.traceFile, opt.ns_to_process, opt.ns_to_skip);
  end

  samples = samples.';
  n_rx_samples = length(samples)

  if (opt.tx_known)
    load(opt.iBitsFile);		%tx data for BER computation
    load(opt.qBitsFile);		%tx data for BER computation
    data.tx_data_bits_i = databits_i; 
    data.tx_data_bits_q = databits_q;
  end

  data.samples = samples;

  pilot_syms = wifi_generate_pilot_syms();

  data.sig_and_data_tx_pilot_syms = [pilot_syms];
  data.pkt_start_point = -1;

  display('------------------- begin find_stream_correlation -------------------');
  tic;
  [stats data] = wifi_find_stream_correlation(data, opt, stats);
  display('------------------- done find_stream_correlation -------------------');
  toc

  if (opt.GENERATE_ONE_TIME_PLOTS_PRE)
    util_plotStreamCorrelation(data.samples, data.abscorrvec, data.abscorrvecsq, ...
    	opt.fig_handle_onetime, opt.subplot_handles_streamcorr)
  end


  data.deinterleave_tables = wifi_deinterleaveTables();

  t = 0;
  ber = 0;
  i = 0;

  %display('start pkt processing?')
  %pause
  while (data.pkt_start_point > -Inf)
    i = i + 1;
    display(strcat('-------------- scale: ',scale,', packet #',int2str(i),'-----------'));
    display(strcat('-------------- last pkt took #',num2str(t),'s to process ----'));

    tic;

    %detect next packet
    display('-------------- detecting next packet --------------')
    [stats data] = wifi_detect_next_packet(data, opt, stats);
    if (data.pkt_start_point == -1)
      display('pkt_start_point is -1, breaking')
      break;
    end

    if (data.pkt_start_point == -Inf)
      display('pkt_start_point is -Inf, breaking')
      break;
    end


    %analyze next packet
    display('-------------- analyzing next packet --------------')
    [stats parsed_data frame_type crcValid rx_data_bits_dec rx_data_bytes] = wifi_rx_chain(data, opt, stats, confStr, cplen);
    display(['frame_type: ',num2str(frame_type),' crcValid: ',num2str(crcValid)])
    if crcValid == -1
      display('this pkt could not be processed through the receive chain, maybe because of insufficient samples')
      %display('continuing without adding this pkt to stats...')
      %continue
    end
    rx_pkts{end+1} = {parsed_data frame_type crcValid rx_data_bits_dec rx_data_bytes};
    ber = stats.ber(end);

    last_pkt_start_point = stats.pkt_start_points(end)
    max_corr_val = stats.max_corr_val

    toc
    t = toc;
    if (opt.PAUSE_AFTER_EVERY_PACKET)
      pause
    end
  end

  %display and summarize stats
  stats = summarizeStats(stats, data, opt);
  stats.opt = opt;
end





%------------------------------------------------------------------------------------
function stats = summarizeStats(stats, data, opt)
%------------------------------------------------------------------------------------
%stats = 
%
%           idle_noise_power: [3x1 double]
%                  stf_power: [3x1 double]
%                  ltf_power: [3x1 double]
%                 data_power: [3x1 double]
%                  pkt_power: [3x1 double]
%                    snr_lin: [3x1 double]
%                     snr_db: [3x1 double]
%      coarse_cfo_angle_corr: [3x1 double]
%    coarse_cfo_freq_off_khz: [3x1 double]
%        fine_cfo_angle_corr: [3x1 double]
%      fine_cfo_freq_off_khz: [3x1 double]
%                        ber: [4x1 double]
%            n_bits_errors_i: [3x1 double]
%             net_snr_linear: [3x1 double]
%                 net_snr_db: [3x1 double]
%            n_bits_errors_q: []
%         ber_vs_ofdm_symbol: [3x250 double]
%         snr_per_subcarrier: [3x48 double]
%      snr_per_subcarrier_db: [3x48 double]
%          ber_vs_subcarrier: [3x48 double]
%               max_corr_val: 0.9658
%    n_packet_start_detected: 4
%               min_max_corr: 0.9534


  display('displaying statistics:');
  %stats

  inpl = length(stats.idle_noise_power)
  idle_noise_power_vector = stats.idle_noise_power(1:stats.n_packets_processed);
  mean_noise_power = mean(idle_noise_power_vector)
  std_noise_power = std(idle_noise_power_vector)

  stats.mean_noise_power = mean_noise_power;
  stats.std_noise_power = std_noise_power;

  snr_db_per_packet = stats.snr_db(1:stats.n_packets_processed);
  ber_per_packet = stats.ber(1:stats.n_packets_processed);

  if (stats.n_packets_processed > 0)
    display('Note: The following avg snr values are meaningful only if the noise vector is fairly constant');
    avg_snr_lin = mean(stats.snr_lin(stats.n_packets_processed))
    avg_snr_db = 10*log10(avg_snr_lin)
    avg_ber = mean(ber_per_packet)

    stats.avg_snr_lin = avg_snr_lin;
    stats.avg_snr_db = avg_snr_db;
    stats.avg_ber = avg_ber;
  else
    display('No packets detected/processed, no average statistics to display')

    stats.avg_snr_lin = -1;
    stats.avg_snr_db = -1;
    stats.avg_ber = -1;
  end

  pkt_start_points = stats.pkt_start_points

  seqs_data = char(stats.seq_vec_data)
  seqs_ack = char(stats.seq_vec_ack)
  seqs_unknown = char(stats.seq_vec_unknown)

  if (opt.writeVars_startPnts)
    writeVars_startPnts(pkt_start_points);
  end

  n_data_packets = length(stats.ber_vec_data);
  n_ack_packets = length(stats.ber_vec_ack);
  n_unknown_packets = length(stats.ber_vec_unknown);
  
  n_crc_data = sum(stats.crc_vec_data);
  n_crc_ack = sum(stats.crc_vec_ack);
  n_crc_unknown = sum(stats.crc_vec_unknown);

  ber_data_avg = mean(stats.ber_vec_data); ber_data_std = std(stats.ber_vec_data);
  ber_ack_avg = mean(stats.ber_vec_ack); ber_ack_std = std(stats.ber_vec_ack);
  ber_unknown_avg = mean(stats.ber_vec_unknown); ber_unknown_std = std(stats.ber_vec_unknown);



  [avg_snr_data snr_v_data] = wifi_find_snr_from_uultfs(stats.uu_ltf1_data, stats.uu_ltf2_data, stats.ch_data);
  [avg_snr_ack snr_v_ack] = wifi_find_snr_from_uultfs(stats.uu_ltf1_ack, stats.uu_ltf2_ack, stats.ch_ack);
  avg_snr_data = avg_snr_data
  avg_snr_ack = avg_snr_ack

  display('=============================================================================================');
  display('Aggregate performance stats: data:');
  display(strcat('n_crc_data/n_data_packets: ', num2str(n_crc_data),'/',num2str(n_data_packets),...
     ' ber_data_avg/ber_data_std: ', num2str(ber_data_avg),'/',num2str(ber_data_std)));
  display(strcat('n_crc_ack/n_ack_packets: ', num2str(n_crc_ack),'/',num2str(n_ack_packets),...
     ' ber_ack_avg/ber_ack_std: ', num2str(ber_ack_avg),'/',num2str(ber_ack_std)));
  display(strcat('n_unknown_packets: ', num2str(n_unknown_packets)));
  display(strcat('n_crc_unknown/n_unknown_packets: ', num2str(n_crc_unknown),'/',num2str(n_unknown_packets),...
     ' ber_unknown_avg/ber_unknown_std: ', num2str(ber_unknown_avg),'/',num2str(ber_unknown_std)));
  crc_vec_data = stats.crc_vec_data
  crc_vec_ack = stats.crc_vec_ack
  crc_vec_unknown = stats.crc_vec_unknown
  snr_db_vec_power_ratio = stats.snr_db.'
  snr_dB_from_data_evm_stats = stats.avgsnr_dB_from_data_evm
  snr_dB_from_plcp_evm_stats = stats.avgsnr_dB_from_plcp_evm
  display('=============================================================================================');

  if (opt.GENERATE_ONE_TIME_PLOTS_PRE)
    util_plotRxSNRs(snr_v_data, snr_v_ack);
  end

  if (opt.writeVars_cfos)
  writeVars_cfos(stats.coarse_cfo_freq_off_khz, stats.fine_cfo_freq_off_khz);
  end



  return
end





%------------------------------------------------------------------------------------
function plotSamples(samples)
%------------------------------------------------------------------------------------
  plot(abs(samples))
end



%------------------------------------------------------------------------------------
function writeVars_startPnts(pkt_start_points)
%------------------------------------------------------------------------------------
  whos
  pkt_start_points(1:10)
  pkt_start_points(end)=[];	%removes the -Inf at the end
  util_writeVarToCFile(pkt_start_points, 'pkt_start_points', 0, 0, 'Uint32', 1, 1);			%Qval = 0 corresponds to integer
end


%------------------------------------------------------------------------------------
function writeVars_cfos(coarse_cfo_freq_off_khz, fine_cfo_freq_off_khz)
%------------------------------------------------------------------------------------
  fprintf(1,'\nbegin writeVars_cfos\n');
  cfo_khz = coarse_cfo_freq_off_khz + fine_cfo_freq_off_khz;	%since on TI, we do a single estimate
  util_writeVarToCFile(cfo_khz, 'cfo_khz', 0, 0, 'float', 1, 1);
  fprintf(1,'end writeVars_cfos\n');
end

