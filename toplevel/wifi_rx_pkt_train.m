function [rx_pkts, pkt_start_points] = wifi_rx_pkt_train(sim_params, copt, opt, samples, confStr, cplen)
  %scale = sqrt(2);
  scale = 'kk';
  %mod = 'jj';

  %[opt, stats] = wifi_rx_parameters('1','54M');
  stats = util_rx_stats();
  opt = util_rx_fig_init(opt);

  rx_pkts = {};

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

  pilot_syms = wifi_generate_pilot_syms(copt);

  data.sig_and_data_tx_pilot_syms = [pilot_syms];
  data.pkt_start_point = -1;

  display('------------------- begin find_stream_correlation -------------------');
  %tic;
  [stats data] = wifi_find_stream_correlation(data, opt, stats);
  display('------------------- done find_stream_correlation -------------------');
  %toc

  if (opt.GENERATE_ONE_TIME_PLOTS_PRE)
    util_plotStreamCorrelation(data.samples, data.abscorrvec, data.abscorrvecsq, ...
    	opt.fig_handle_onetime, opt.subplot_handles_streamcorr)
  end


  data.deinterleave_tables = wifi_deinterleaveTables(opt, sim_params);

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
    [pkt_start_point stats data] = wifi_detect_next_packet(data, opt, stats);
    data.pkt_start_point = pkt_start_point;

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
    [stats parsed_data frame_type crcValid rx_data_bits_dec rx_data_bytes] = wifi_rx_chain(data, sim_params, copt, opt, stats, confStr, cplen);
    display(['frame_type: ',num2str(frame_type),' crcValid: ',num2str(crcValid)])
    if crcValid == -1
      display('this pkt could not be processed through the receive chain, maybe because of insufficient samples')
      %display('continuing without adding this pkt to stats...')
      %continue
    end
    rx_pkts{end+1} = {parsed_data frame_type crcValid rx_data_bits_dec rx_data_bytes};
    ber = stats.ber(end);

    last_pkt_start_point = stats.pkt_start_points(end);
    max_corr_val = stats.max_corr_val;
    display(['last_pkt_start_point: ' num2str(last_pkt_start_point) ...
    	'  max_corr_val: ' num2str(max_corr_val)]);

    toc
    t = toc;
    if (opt.PAUSE_AFTER_EVERY_PACKET)
      pause
    end
  end

  %display and summarize stats
  stats = util_summarizeStats(stats, data, opt);
  %util_displayStats(stats, opt);

  stats.opt = opt;
  pkt_start_points = stats.pkt_start_points;
end
