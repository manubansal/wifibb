function util_displayStats(stats, opt)
  display('displaying statistics:');
  %stats

  inpl = length(stats.idle_noise_power)
  idle_noise_power_vector = stats.idle_noise_power(1:stats.n_packets_processed);
  mean_noise_power = stats.mean_noise_power
  std_noise_power = stats.std_noise_power

  snr_db_per_packet = stats.snr_db(1:stats.n_packets_processed);
  ber_per_packet = stats.ber(1:stats.n_packets_processed);

  if (stats.n_packets_processed > 0)
    display('Note: The following avg snr values are meaningful only if the noise vector is fairly constant');
    avg_snr_lin = stats.avg_snr_lin
    avg_snr_db = stats.avg_snr_db
    avg_ber = stats.avg_ber
  else
    display('No packets detected/processed, no average statistics to display')
  end

  pkt_start_points = stats.pkt_start_points

  seqs_data = char(stats.seq_vec_data)
  seqs_ack = char(stats.seq_vec_ack)
  seqs_unknown = char(stats.seq_vec_unknown)


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
end
