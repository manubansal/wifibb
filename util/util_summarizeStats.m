
%------------------------------------------------------------------------------------
function stats = util_summarizeStats(stats, data, opt)
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



  idle_noise_power_vector = stats.idle_noise_power(1:stats.n_packets_processed);
  mean_noise_power = mean(idle_noise_power_vector);
  std_noise_power = std(idle_noise_power_vector);

  stats.mean_noise_power = mean_noise_power;
  stats.std_noise_power = std_noise_power;

  snr_db_per_packet = stats.snr_db(1:stats.n_packets_processed);
  ber_per_packet = stats.ber(1:stats.n_packets_processed);

  if (stats.n_packets_processed > 0)
    stats.avg_snr_lin = mean(stats.snr_lin(stats.n_packets_processed));
    stats.avg_snr_db = 10*log10(stats.avg_snr_lin);
    stats.avg_ber = mean(ber_per_packet);
  else
    stats.avg_snr_lin = -1;
    stats.avg_snr_db = -1;
    stats.avg_ber = -1;
  end


  if (opt.writeVars_startPnts)
    pkt_start_points = stats.pkt_start_points;
    writeVars_startPnts(pkt_start_points);
  end


  if (opt.writeVars_cfos)
  writeVars_cfos(stats.coarse_cfo_freq_off_khz, stats.fine_cfo_freq_off_khz);
  end

  return
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

