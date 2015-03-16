function rx_pkts = wifi_rx_pkt_constellation_train(samples, confStr, rate, payload_len)
  rx_pkts = {}

  %scale = sqrt(2);
  scale = 'kk';
  %mod = 'jj';

  [opt, stats] = wifi_rx_parameters();

  samples = samples.';
  n_rx_samples = length(samples)

  %data.samples = samples;

  pilot_syms = wifi_generate_pilot_syms();

  data.sig_and_data_tx_pilot_syms = [pilot_syms];

  data.deinterleave_tables = wifi_deinterleaveTables();

  t = 0;
  ber = 0;
  i = 0;

  display('start pkt processing?')
  pause

  rx_sig_field = wifi_pack_signal(rate, payload_len);
  [t_rate t_len t_modu t_code t_parityCheck t_valid t_ndbps t_nsyms] = wifi_parse_signal(rx_sig_field);
  n_ofdm_syms = t_nsyms;
  n_cplx_samples_per_pkt = n_ofdm_syms * 48;

  pkt_start_point = 0;
  while (pkt_start_point > -Inf)
    i = i + 1;
    display(strcat('-------------- scale: ',scale,', packet #',int2str(i),'-----------'));
    display(strcat('-------------- last pkt took #',num2str(t),'s to process ----'));

    tic;

    %get next packet
    if pkt_start_point + n_cplx_samples_per_pkt > length(samples)
      display('end of trace')
      break;
    end
    pkt_samples = samples((pkt_start_point + 1):(pkt_start_point + n_cplx_samples_per_pkt));

    %analyze next packet
    display('-------------- analyzing next packet --------------')
    [stats parsed_data frame_type crcValid rx_data_bits_dec] = wifi_rx_chain_constellation(pkt_samples, rate, payload_len, data, opt, stats, confStr);
    display(['frame_type: ',num2str(frame_type),' crcValid: ',num2str(crcValid)])
    rx_pkts{end+1} = {parsed_data frame_type crcValid rx_data_bits_dec};
    %ber = stats.ber(end);

    last_pkt_start_point = pkt_start_point
    %last_pkt_start_point = pkt_start_point + 1
    %max_corr_val = stats.max_corr_val

    toc
    t = toc;
    if (opt.PAUSE_AFTER_EVERY_PACKET)
      pause
    end

    %detect next packet
    pkt_start_point = pkt_start_point + n_cplx_samples_per_pkt
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

  if (stats.n_packets_processed > 0)
    display('Note: The following avg snr values are meaningful only if the noise vector is fairly constant');
    %avg_snr_lin = mean(stats.snr_lin(stats.n_packets_processed))
    %avg_snr_db = 10*log10(avg_snr_lin)
    %avg_ber = mean(ber_per_packet)

    %stats.avg_snr_lin = avg_snr_lin;
    %stats.avg_snr_db = avg_snr_db;
    %stats.avg_ber = avg_ber;
    stats.avg_snr_lin = -1;
    stats.avg_snr_db = -1;
    stats.avg_ber = -1;
  else
    display('No packets detected/processed, no average statistics to display')

    stats.avg_snr_lin = -1;
    stats.avg_snr_db = -1;
    stats.avg_ber = -1;
  end

  pkt_start_points = stats.pkt_start_points

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



  %[avg_snr_data snr_v_data] = wifi_find_snr_from_uultfs(stats.uu_ltf1_data, stats.uu_ltf2_data, stats.ch_data);
  %[avg_snr_ack snr_v_ack] = wifi_find_snr_from_uultfs(stats.uu_ltf1_ack, stats.uu_ltf2_ack, stats.ch_ack);
  %avg_snr_data = avg_snr_data
  %avg_snr_ack = avg_snr_ack

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
  display('=============================================================================================');

  %if (opt.GENERATE_ONE_TIME_PLOTS_PRE)
  %  util_plotRxSNRs(snr_v_data, snr_v_ack);
  %end

  return
end
