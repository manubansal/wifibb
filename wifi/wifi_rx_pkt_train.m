function wifi_rx_pkt_train(samples)
  %scale = sqrt(2);
  scale = 'kk';
  %mod = 'jj';

  %[opt, stats] = wifi_rx_parameters(scale, mod, opt);
  %[opt, stats] = wifi_rx_parameters(scale, mod);
  %[opt, stats] = wifi_rx_parameters(scale);
  [opt, stats] = wifi_rx_parameters();


  if length(samples) == 0
  %  samples = util_loadBinaryFile(opt.traceFile);
  %  if (opt.ns_to_process == 0)
  %    last_sample = length(samples);
  %  else
  %    last_sample = (opt.ns_to_process+opt.ns_to_skip);
  %  end
  %  samples = samples((1+opt.ns_to_skip):last_sample);
    samples = util_loadBinaryFilePart(opt.traceFile, opt.ns_to_process, opt.ns_to_skip);
  end

  samples = samples.';
  n_rx_samples = length(samples)
  %pause

  if (opt.tx_known)
    load(opt.iBitsFile);		%tx data for BER computation
    load(opt.qBitsFile);		%tx data for BER computation
    data.tx_data_bits_i = databits_i; 
    data.tx_data_bits_q = databits_q;
  end
  %data.mod = opt.mod;

  data.samples = samples;

  %%%%%%%%%%%%pilot_syms = wifi_generate_pilot_syms(opt.nsyms_data);
  pilot_syms = wifi_generate_pilot_syms();

  %size(pilot_syms)
  %%%%data.sig_and_data_tx_pilot_syms = [pilot_syms(:,1) pilot_syms];	%NO! signal and data symbols draw from the same seq
  data.sig_and_data_tx_pilot_syms = [pilot_syms];
  %size(data.sig_and_data_tx_pilot_syms)
  %pause
  %data.pkt_start_point = -opt.pkt_length_samples;
  data.pkt_start_point = -1;

  %%% THIS 1
  %%%%display('------------------- begin detectPackets -------------------');
  %%%%tic;
  %%%%[stats data] = detectPackets(data, opt, stats);
  %%%%display('------------------- done detectPackets -------------------');
  %%%%toc

  %%%t = 0;
  %%%for i = 1:data.n_packets_detected
  %%%  display(strcat('-------------- packet #',int2str(i),' of #',num2str(data.n_packets_detected),' ---- '));
  %%%  display(strcat('-------------- last pkt took #',num2str(t),'s to process ----'));
  %%%  tic;
  %%%  data.pkt_start_point = stats.pkt_start_points(i);
  %%%  stats = analyzeSinglePacket(data, opt, stats);
  %%%  toc
  %%%  t = toc;
  %%%end
  %%% THIS 1

  %%% OR THIS 2
  display('------------------- begin find_stream_correlation -------------------');
  tic;
  [stats data] = wifi_find_stream_correlation(data, opt, stats);
  display('------------------- done find_stream_correlation -------------------');
  toc

  data.deinterleave_tables = wifi_deinterleaveTables();

  t = 0;
  ber = 0;
  i = 0;
  %while (ber ~= -1) 
  while (data.pkt_start_point > -Inf)
    i = i + 1;
    display(strcat('-------------- scale: ',scale,', packet #',int2str(i),'-----------'));%,' of #',num2str(data.n_packets_detected),' ---- '));
    display(strcat('-------------- last pkt took #',num2str(t),'s to process ----'));

    tic;

    %detect next packet
    [stats data] = wifi_detect_next_packet(data, opt, stats);
    if (data.pkt_start_point == -1)
      break;
    end

    %if (data.pkt_start_point == -2)	%pkt_start_point was too early for us to find noise
    %  continue;			%don't analyze, since we couldn't get the right stats out
    %end

    if (data.pkt_start_point == -Inf)
      break;
    end


    %analyze next packet
    %stats = analyzeSinglePacket(data, opt, stats);
    stats = wifi_rx_chain(data, opt, stats);
    ber = stats.ber(end);

    %remove the analyzed packet from sample stream and associated data structures
    %%%data.samples(1:min(data.pkt_start_point+opt.pkt_length_samples-1,end)) = [];
    %%%data.corrvec(1:min(data.pkt_start_point+opt.pkt_length_samples-1,end)) = [];
    %%%data.abscorrvec(1:min(data.pkt_start_point+opt.pkt_length_samples-1,end)) = [];

    last_pkt_start_point = stats.pkt_start_points(end)
    max_corr_val = stats.max_corr_val

    toc
    t = toc;
    if (opt.PAUSE_AFTER_EVERY_PACKET)
      pause
    end
  end
  %%% THIS 2

  %display and summarize stats
  stats = summarizeStats(stats, data, opt);
  stats.opt = opt;
end





%----------------------------------------------------------------------------------------------------------------------------
function stats = summarizeStats(stats, data, opt)
%----------------------------------------------------------------------------------------------------------------------------
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






  %size(stats.uu_ltf1_data)
  %size(stats.uu_ltf2_data)
  %size(stats.ch_data)

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
  display('=============================================================================================');

  %opt.GENERATE_ONE_TIME_PLOTS = true;

  if (opt.GENERATE_ONE_TIME_PLOTS)
    figure
    plot(1:length(snr_v_data), snr_v_data, 'b')
    hold on
    plot(1:length(snr_v_ack), snr_v_ack, 'r')
    ylim([0 50]);
    grid on
    title('avg snr of data (b) and ack (r) pkts (dB), dc in the middle');
  end

  if (opt.writeVars_cfos)
  writeVars_cfos(stats.coarse_cfo_freq_off_khz, stats.fine_cfo_freq_off_khz);
  end



  return
end





%----------------------------------------------------------------------------------------------------------------------------
function plotSamples(samples)
%----------------------------------------------------------------------------------------------------------------------------
  plot(abs(samples))
end



%----------------------------------------------------------------------------------------------------------------------------
function writeVars_startPnts(pkt_start_points)
%----------------------------------------------------------------------------------------------------------------------------
  whos
  pkt_start_points(1:10)
  pkt_start_points(end)=[];	%removes the -Inf at the end
  util_writeVarToCFile(pkt_start_points, 'pkt_start_points', 0, 0, 'Uint32', 1, 1);			%Qval = 0 corresponds to integer
end


%----------------------------------------------------------------------------------------------------------------------------
function writeVars_cfos(coarse_cfo_freq_off_khz, fine_cfo_freq_off_khz)
%----------------------------------------------------------------------------------------------------------------------------
  fprintf(1,'\nbegin writeVars_cfos\n');
  cfo_khz = coarse_cfo_freq_off_khz + fine_cfo_freq_off_khz;	%since on TI, we do a single estimate
  util_writeVarToCFile(cfo_khz, 'cfo_khz', 0, 0, 'float', 1, 1);
  fprintf(1,'end writeVars_cfos\n');
end

