function stats = util_rx_stats()
  %----------------------------------------

  stats.idle_noise_power = [];
  stats.stf_power = [];
  stats.ltf_power = [];
  stats.sig_power = [];
  stats.data_power = [];
  stats.pkt_power = [];

  stats.snr_lin = [];
  stats.snr_db = [];
  stats.avgsnr_dB_from_data_evm = [];
  stats.avgsnr_dB_from_plcp_evm = [];

  stats.coarse_cfo_angle_corr = [];
  stats.coarse_cfo_freq_off_khz = [];

  stats.fine_cfo_angle_corr = [];
  stats.fine_cfo_freq_off_khz = [];

  stats.ber = [];

  stats.n_bits_errors_i = [];

  stats.net_snr_linear = [];
  stats.net_snr_db = [];

  stats.n_bits_errors_q = [];

  stats.ber_vs_ofdm_symbol = [];
  stats.snr_per_subcarrier = [];
  stats.snr_per_subcarrier_db = [];
  stats.ber_vs_subcarrier = [];

  stats.n_packets_processed = 0;
  stats.pkt_start_points = [];

  stats.min_max_corr_val = 2.0;
  stats.max_max_corr_val = 0.0;


  stats.ber_vec_data = [];
  stats.crc_vec_data = [];
  stats.seq_vec_data = [];

  stats.ber_vec_ack = [];
  stats.crc_vec_ack = [];
  stats.seq_vec_ack = [];

  stats.ber_vec_unknown = [];
  stats.crc_vec_unknown = [];
  stats.seq_vec_unknown = [];


  stats.uu_ltf1_data = []; stats.uu_ltf2_data = []; stats.ch_data = [];
  stats.uu_ltf1_ack = []; stats.uu_ltf2_ack = []; stats.ch_ack = [];
  stats.uu_ltf1_unknown = []; stats.uu_ltf2_unknown = []; stats.ch_unknown = [];

  stats.all_ltf1_64 = [];
  stats.all_ltf2_64 = [];
  stats.all_ltf_av_64 = [];
  stats.all_channel_64 = [];

  %----------------------------------------
end
