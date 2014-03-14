%------------------------------------------------------------------------------------
function [stats parsed_data frame_type crcValid rx_data_bits_dec rx_data_bytes] = wifi_rx_chain(data, opt, stats, confStr)
%------------------------------------------------------------------------------------
  rx_data_bytes = [];

  stf_len = opt.stf_len;
  ltf_len = opt.ltf_len;
  sig_len = opt.sig_len;

  [stats data pkt_samples] 			= wifi_get_packet(data, opt, stats);
  display(['Got pkt at power-ratio estimated dB SNR = ' num2str(stats.snr_db(end))])
  power_ratio_SNR_dB = (stats.snr_db(end));

  %base ltf samples, before any rx processing
  ltf_samples = pkt_samples(stf_len+1:stf_len+ltf_len);
  if (opt.dumpVars_ltfRxSamples)
    util_dumpData('ltfRxSamples', confStr, ltf_samples)
  end


  %base signal field samples, before any rx processing
  sig_samples = pkt_samples(stf_len+ltf_len+1:stf_len+ltf_len+sig_len);
  data_samples = pkt_samples(stf_len+ltf_len+sig_len+1:end);

  if (opt.dumpVars_plcpBaseSamples)
    util_dumpData('plcpBaseSamples', confStr, sig_samples)
  end

  if (opt.dumpVars_dataBaseSamples)
    util_dumpData('dataBaseSamples', confStr, data_samples)
  end


  [stats, pkt_samples, coarse_cfo_freq_off_khz] = ...
  	wifi_coarse_cfo_correction(opt, stats, pkt_samples, data.corrvec, data.pkt_start_point);
  [stats, pkt_samples, fine_cfo_freq_off_khz] = ...
  	wifi_fine_cfo_correction(opt, stats, pkt_samples);

  net_cfo_freq_off_khz = coarse_cfo_freq_off_khz + fine_cfo_freq_off_khz

  %signal field samples after cfo correction
  sig_samples = pkt_samples(stf_len+ltf_len+1:stf_len+ltf_len+sig_len);
  data_samples = pkt_samples(stf_len+ltf_len+sig_len+1:end);
  if (opt.dumpVars_plcpCfoCorrected)
    util_dumpData('plcpCfoCorrected', confStr, sig_samples)
  end
  if (opt.dumpVars_dataCfoCorrected)
    util_dumpData('dataCfoCorrected', confStr, data_samples)
  end


  [stats, uu_ltf1, uu_ltf2, ltf1_f, ltf2_f, ltf_f_av, ch, ch_abs_db, chi] ...
  		= wifi_preamble_channel_estimation(opt, stats, pkt_samples);

  [avgsnr avgsnr_dB snr_vector snr_vector_dB avgsnr_cross_dB] = util_ltfSNR(uu_ltf1, uu_ltf2, chi);
  ltf_avgsnr_dB = avgsnr_dB
  ltf_avgsnr_dB_cross = avgsnr_cross_dB

  sig_samples = pkt_samples(stf_len+ltf_len+1:stf_len+ltf_len+sig_len);
  data_samples = pkt_samples(stf_len+ltf_len+sig_len+1:end);

  data.cleanupDone = 1;


  if (~opt.GENERATE_PER_PACKET_PLOTS_ONLY_ON_FILTER_MATCH)
    if (opt.GENERATE_PER_PACKET_PLOTS && opt.GENERATE_PER_PACKET_PLOTS_CHANNEL)
      util_plot_channel_estimates(ltf1_f, ltf2_f, ltf_f_av, ch, ch_abs_db, uu_ltf1, uu_ltf2, ...
	  opt.figure_handle_perpkt, opt.subplot_handles_channel)
    end
  end


  if (~data.cleanupDone)
    display('ERROR: wifi cleanup of packet failed');
    return;
  end
  stats.n_packets_processed = stats.n_packets_processed + 1;

  %%********************************
  %%%%%%%%% process signal field
  %%********************************

  nbpsc = 1;	%signal field is coded with bpsk
  nsyms = 1;	%signal field occupies one ofdm symbol

  [stats data ofdm_syms_f]  		= wifi_ofdm_demod(sig_samples, nsyms, data, opt, stats);

  %++++++++++++++++++++++++++++++++++++++++++++++
  [ig1, ig2, ig3, ig4, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameters(0);
  %%%%%%%%%%%%%%%%%%%%%%%
  if (opt.printVars_ofdmDemodPlcp)
    display('plcp signal field in frequency domain before equalization');
      display('plcp data subcarriers:');
    [ [1:48]' fix(opt.ti_factor_after_cfo * ofdm_syms_f(dsubc_idx, 1))]
      display('plcp pilot subcarriers:');
    tx_pilot_syms = data.sig_and_data_tx_pilot_syms(:,1:nsyms);
    [ [1:4]' fix(opt.ti_factor_after_cfo * (ofdm_syms_f(psubc_idx, 1) .* conj(tx_pilot_syms(:,1))))]
  end
  %%%%%%%%%%%%%%%%%%%%%%%

  if (opt.dumpVars_plcpOfdmDemod)
    util_dumpData('plcpOfdmDemod', confStr, fix(opt.ti_factor_after_cfo * ofdm_syms_f(dsubc_idx, 1)))
  end
  %++++++++++++++++++++++++++++++++++++++++++++++

  [stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] ...
		    = wifi_channel_correction(nsyms, opt, data, stats, ofdm_syms_f, chi);

  [stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] ...
		    = wifi_pilot_phase_tracking(stats, data, opt, ofdm_syms_f, uu_pilot_syms, nsyms);

  [stats data rx_data_syms rx_pilot_syms uu_pilot_syms ofdm_syms_f] ...
		    = wifi_pilot_sampling_delay_correction(stats, data, opt, ofdm_syms_f, uu_pilot_syms, nsyms);

  %++++++++++++++++++++++++++++++++++++++++++++++
  if (opt.dumpVars_plcpOfdmEq)
    %util_dumpData('plcpOfdmEq.eqPnts', confStr, fix(ofdm_syms_f(dsubc_idx, 1)))
    util_dumpData('plcpOfdmEq.eqPnts', confStr, ofdm_syms_f(dsubc_idx, 1))
    util_dumpData('plcpOfdmEq.channeli', confStr, chi)
    [ig1, ig2, ig3, ig4, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameters(0);

    ch_dsubc = ch(dsubc_idx);
    util_dumpData('plcpOfdmEq.channel_dsubc', confStr, ch_dsubc)

    ch_psubc = ch(psubc_idx);
    util_dumpData('plcpOfdmEq.channel_psubc', confStr, ch_psubc)
  end
  %++++++++++++++++++++++++++++++++++++++++++++++

  plcp_rx_data_syms = rx_data_syms;

  if (~opt.GENERATE_PER_PACKET_PLOTS_ONLY_ON_FILTER_MATCH)
      % plot the constellation for plcp part
      if (opt.GENERATE_PER_PACKET_PLOTS && opt.GENERATE_PER_PACKET_PLOTS_CONSTELLATION)
	util_plotConstellation(rx_data_syms, ...
	    opt.figure_handle_perpkt, opt.subplot_handles_constellation);
      end

      %NOTE: the following can be very inaccurate. ltf SNR is a much better estimate.
      %[avgsnr avgsnr_dB snr_vector snr_vector_dB] = util_constellationSNR(rx_data_syms, nbpsc);
      %plcp_constellation_avgsnr_dB = avgsnr_dB

      if (opt.GENERATE_PER_PACKET_PLOTS || opt.GENERATE_PER_PACKET_PLOTS_CONSTELLATION)
	[stats data] = util_plotConstellation2(stats, data, uu_pilot_syms, ...
	    opt.figure_handle_perpkt, opt.subplot_handles_constellation2);
      end
  end

  ltf_avgsnr_dB = ltf_avgsnr_dB
  ltf_avgsnr_dB_cross = ltf_avgsnr_dB_cross

  display('plotted plcp constellation, continue?')
  %pause

  [rx_data_bits]  		= wifi_wrapper_demap_packet(rx_data_syms, nsyms, nbpsc, opt.soft_slice_nbits);

  util_print_demapPacket_plcp(rx_data_bits, opt);

  %++++++++++++++++++++++++++++++++++++++++++++++
  if (opt.dumpVars_plcpDemap)
    nbits = opt.soft_slice_nbits;
    scale = 2^(nbits - 1);		%for 8 bits, this is 128, so that we can 
    					%contain the soft estimates in [-128, 128]

    %(rx_data_bits(:,1) - scale)	%representing in [-scale, scale], instead of [0, 2*scale]
    dumped_soft_bits = rx_data_bits(:,1) - scale;
    util_dumpData('plcpDemap', confStr, dumped_soft_bits)
  end
  %++++++++++++++++++++++++++++++++++++++++++++++

  [stats ber]   	     		= util_computeModulationBER(data, opt, stats);
  [stats data rx_data_bits_deint]       = wifi_wrapper_deinterleave(data, opt, stats, rx_data_bits, nbpsc);

  [rx_data_bits_dec]         = wifi_wrapper_decode(rx_data_bits_deint, 18, opt);
  if (opt.writeVars_decode)
    writeVars_decode(rx_data_bits_deint, opt.soft_slice_nbits, opt.tblen_signal, rx_data_bits_dec);
  end

  [stats data]				= wifi_parse_signal_top(data, opt, stats, rx_data_bits_dec);

  %%*********************************
  %%%%%% decide whether to process data field
  %%*********************************


  nbpsc = data.sig_modu;
  nsyms = data.sig_nsyms;
  coderate = data.sig_code;

  not_enough_samples = false;
  if (length(data_samples) < nsyms * opt.sym_len_s)
    not_enough_samples = true;
  end


  if (~(data.sig_valid && data.sig_parityCheck) || not_enough_samples)
    parsed_data = [];
    frame_type = -1;
    ber = -1;
    crcValid = -1;
    data.frame_type = frame_type;

    %%***************************************
    %% display plcp intermediaries/results
    %%***************************************
    display('------------------------------------------------------------');
    display('parse data results: ');
    display(strcat('frame_type (0: data, 1: ack, 2: unknown):', num2str(frame_type), ...
      ' ber:', num2str(ber), ' crcValid:', num2str(crcValid)));
    display('------------------------------------------------------------');

    %%***************************************
    %% update statistics
    %%***************************************
    stats = updateStats(data, opt, stats, uu_ltf1, uu_ltf2, ch);

    if (not_enough_samples)
      display('ERROR: not enough data samples in the trace, continuing without data decode...')
    else
      display('signal field not valid, continuing without data decode...')
    end

    return
  end


  %filter_match = data.sig_rate == 54 && data.sig_payload_length == 1475;
  %filter_match = data.sig_rate == 54 && data.sig_payload_length == 1514;
  filter_match = data.sig_rate == 54 && data.sig_payload_length == 15;
  %filter_match = true;



  if (filter_match)
    if (opt.GENERATE_PER_PACKET_PLOTS_ONLY_ON_FILTER_MATCH)
	% plot channel stuff
	if (opt.GENERATE_PER_PACKET_PLOTS && opt.GENERATE_PER_PACKET_PLOTS_CHANNEL)
	  util_plot_channel_estimates(ltf1_f, ltf2_f, ltf_f_av, ch, ch_abs_db, uu_ltf1, uu_ltf2, ...
	      opt.figure_handle_perpkt, opt.subplot_handles_channel)
	end

	% plot the constellation for plcp part
	if (opt.GENERATE_PER_PACKET_PLOTS && opt.GENERATE_PER_PACKET_PLOTS_CONSTELLATION)
	  util_plotConstellation(rx_data_syms, ...
	      opt.figure_handle_perpkt, opt.subplot_handles_constellation);
	end

	%NOTE: the following can be very inaccurate. ltf SNR is a much better estimate.
	%[avgsnr avgsnr_dB snr_vector snr_vector_dB] = util_constellationSNR(rx_data_syms, nbpsc);
	%plcp_constellation_avgsnr_dB = avgsnr_dB

	if (opt.GENERATE_PER_PACKET_PLOTS && opt.GENERATE_PER_PACKET_PLOTS_CONSTELLATION)
	  [stats data] = util_plotConstellation2(stats, data, uu_pilot_syms, ...
	      opt.figure_handle_perpkt, opt.subplot_handles_constellation2);
	end
    end

    display('found a filter-matching plcp. plotted plcp constellation, continue?')
    pause
  end


  %%*********************************
  %%%%%% process data field
  %%*********************************

  [stats data ofdm_syms_f]  		= wifi_ofdm_demod([sig_samples data_samples], nsyms+ 1, data, opt, stats);

  %++++++++++++++++++++++++++++++++++++++++++++++
  if (opt.dumpVars_dataOfdmDemod)
    util_dumpData('dataOfdmDemod', confStr, ofdm_syms_f(dsubc_idx, 2:end))
  end
  %++++++++++++++++++++++++++++++++++++++++++++++

  [stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] = wifi_channel_correction(nsyms + 1, opt, data, stats, ofdm_syms_f, chi);
  [stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] = wifi_pilot_phase_tracking(stats, data, opt, ofdm_syms_f, uu_pilot_syms, nsyms + 1);
  [stats data rx_data_syms rx_pilot_syms uu_pilot_syms ofdm_syms_f] = ...
	wifi_pilot_sampling_delay_correction(stats, data, opt, ofdm_syms_f, uu_pilot_syms, nsyms + 1);

  if (~opt.GENERATE_PER_PACKET_PLOTS_ONLY_ON_FILTER_MATCH || filter_match)
      if (opt.GENERATE_PER_PACKET_PLOTS && opt.GENERATE_PER_PACKET_PLOTS_CONSTELLATION)
	[stats data] = util_plotConstellation2(stats, data, uu_pilot_syms, ...
	    opt.figure_handle_perpkt, opt.subplot_handles_constellation2);
      end
  end


  rx_data_syms(:,1)=[];
  rx_data_syms = rx_data_syms(:,1:nsyms);

  ofdm_syms_f = ofdm_syms_f(:,2:end);

  %++++++++++++++++++++++++++++++++++++++++++++++
  if (opt.printVars_equalize)
    util_print_equalize(rx_data_syms);
  end
  %++++++++++++++++++++++++++++++++++++++++++++++

  %++++++++++++++++++++++++++++++++++++++++++++++
  if (opt.dumpVars_dataOfdmEq)
    %util_dumpData('dataOfdmEq.eqPnts', fix(opt.ti_factor_after_cfo * ofdm_syms_f(dsubc_idx, :)))
    util_dumpData('dataOfdmEq.eqPnts', confStr, ofdm_syms_f(dsubc_idx, :))
    %util_dumpData('dataOfdmEq.channeli', chi)
    %[ig1, ig2, ig3, ig4, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameters(0);

    %ch_dsubc = ch(dsubc_idx)
    %util_dumpData('dataOfdmEq.channel_dsubc', ch_dsubc)

    %ch_psubc = ch(psubc_idx)
    %util_dumpData('dataOfdmEq.channel_psubc', ch_psubc)
  end
  %++++++++++++++++++++++++++++++++++++++++++++++


  %NOTE: the following can be very inaccurate. ltf SNR is a much better estimate.
  [avgsnr avgsnr_dB snr_vector snr_vector_dB] = util_constellationSNR(rx_data_syms, nbpsc);
  data_constellation_avgsnr_dB_overestimate = avgsnr_dB

  % plot the constellation for data part
  if (~opt.GENERATE_PER_PACKET_PLOTS_ONLY_ON_FILTER_MATCH || filter_match)
    if (opt.GENERATE_PER_PACKET_PLOTS && opt.GENERATE_PER_PACKET_PLOTS_CONSTELLATION)
      util_plotConstellation(rx_data_syms, ...
	  opt.figure_handle_perpkt, opt.subplot_handles_constellation);
    end
  end

  %display('plotted data constellation, continue?')
  %pause


  [rx_data_bits]  		= wifi_wrapper_demap_packet(rx_data_syms, data.sig_nsyms, data.sig_modu, opt.soft_slice_nbits);

  util_print_demapPacket_data(rx_data_bits, opt);

  %++++++++++++++++++++++++++++++++++++++++++++++
  if (opt.dumpVars_dataDemap)
    nbits = opt.soft_slice_nbits;
    scale = 2^(nbits - 1);		%for 8 bits, this is 128, so that we can 
    					%contain the soft estimates in [-128, 128]

    %(rx_data_bits(:,1) - scale)	%representing in [-scale, scale], instead of [0, 2*scale]
    dumped_soft_bits = rx_data_bits(:,:) - scale;
    util_dumpData('dataDemap', confStr, dumped_soft_bits)
  end
  %++++++++++++++++++++++++++++++++++++++++++++++


  %[stats ber]   	     		= util_computeModulationBER(data, opt, stats);
  [stats data rx_data_bits_deint]  	= wifi_wrapper_deinterleave(data, opt, stats, rx_data_bits, nbpsc);

  if (opt.printVars_deinterleave)
    util_print_deinterleave(rx_data_bits_deint);
  end

  rx_data_bits_deint = reshape(rx_data_bits_deint, prod(size(rx_data_bits_deint)), 1);
  [stats data rx_data_bits_depunct]     = wifi_wrapper_depuncture(data, opt, stats, rx_data_bits_deint, coderate);


  %++++++++++++++++++++++++++++++++++++++++++++++
  if (opt.dumpVars_dataDemap)
    nbits = opt.soft_slice_nbits;
    scale = 2^(nbits - 1);		%for 8 bits, this is 128, so that we can 
    					%contain the soft estimates in [-128, 128]

    %(rx_data_bits(:,1) - scale)	%representing in [-scale, scale], instead of [0, 2*scale]
    dumped_soft_bits_depunct = rx_data_bits_depunct(:,1) - scale;
    util_dumpData('dataDepunct', confStr, dumped_soft_bits_depunct)
  end
  %++++++++++++++++++++++++++++++++++++++++++++++

  %decode the actual data length portion
  data_and_tail_length_bits = 16 + data.sig_payload_length * 8 + 6;	%first 16 for service, last 6 for tail
  actual_data_portion_with_tail = rx_data_bits_depunct(1:(data_and_tail_length_bits * 2));	%since it's a half rate code

  [rx_data_bits_dec]         = wifi_wrapper_decode(actual_data_portion_with_tail, 16 + data.sig_payload_length * 8, opt);
  if (opt.writeVars_decode)
    writeVars_decode(actual_data_portion_with_tail, opt.soft_slice_nbits, opt.tblen_data, rx_data_bits_dec);
  end

  if (opt.printVars_decodedBits)
    all_chunks = ...
     util_print_decode(rx_data_bits_dec, data.sig_ndbps, opt.n_decoded_symbols_per_ofdm_symbol);
  end

  %++++++++++++++++++++++++++++++++++++++++++++++
  if (opt.dumpVars_dataVitdecChunks)
    if (opt.printVars_decodedBits)
      util_dumpData('dataVitdecChunks', confStr, all_chunks)
    else
      fprint(1, 'Need opt.printVars_decodedBits for opt.dumpVars_dataVitdecChunks\n');
    end
  end
  %++++++++++++++++++++++++++++++++++++++++++++++

  %++++++++++++++++++++++++++++++++++++++++++++++
  if (opt.dumpVars_dataVitdec)
    util_dumpData('dataVitdec', confStr, rx_data_bits_dec)
  end
  %++++++++++++++++++++++++++++++++++++++++++++++


  %------------------------------------------------------------------------------------
  rx_data_bits_descr = wifi_descramble(rx_data_bits_dec);
  %------------------------------------------------------------------------------------

  if (opt.printVars_descrambledBits)
    util_print_descramble(rx_data_bits_descr, data.sig_ndbps);
  end

  %rx_data_bytes = reshape(rx_data_bits_descr, 8, length(rx_data_bits_descr)/8);

  %retain only upto the data portion, including service field but discarding tail and pad
  rx_data_bits_descr = rx_data_bits_descr(1:(16+data.sig_payload_length * 8));
  rx_data_bytes = reshape(rx_data_bits_descr, 8, data.sig_payload_length + 2);
  size_rx_data_bytes = size(rx_data_bytes);

  %++++++++++++++++++++++++++++++++++++++++++++++
  if (opt.dumpVars_dataDescr)
    util_dumpData('dataDescr', confStr, rx_data_bits_descr)
  end
  %++++++++++++++++++++++++++++++++++++++++++++++



  [parsed_data frame_type ber crcValid service_field da seq] = wifi_parse_payload(rx_data_bytes);
  data.parsed_data = parsed_data;
  data.frame_type = frame_type;
  data.ber = ber;
  data.crcValid = crcValid;
  data.service_field = service_field;
  data.da = da;
  data.seq = seq;

  if (opt.printVars_parsedData)
    util_printHexOctets(parsed_data);
  end

  %++++++++++++++++++++++++++++++++++++++++++++++
  if (opt.dumpVars_dataParsed)
    if (filter_match)
      util_dumpData('dataParsed', confStr, parsed_data)
    end
  end
  %++++++++++++++++++++++++++++++++++++++++++++++



  %%***************************************
  %% display data intermediaries/results
  %%***************************************
  if (opt.printVars_data_syms)
	  util_print_data_syms(...
	    opt, ...
	    data,...
	    rx_data_syms, ...
	    rx_data_bits, ...
	    rx_data_bits_deint,...
	    rx_data_bits_dec...
	    );
  end

  %%***************************************
  %% display plcp intermediaries/results
  %%***************************************
  display('---------------------------------------------------------------------');
  display('parse data results: ');
  display(strcat('frame_type (0: data, 1: ack, 2: unknown):', num2str(frame_type), ...
    ' ber:', num2str(ber), ' seq:', seq, ' crcValid:', num2str(crcValid)));
  display('---------------------------------------------------------------------');

  power_ratio_SNR_dB = (stats.snr_db(end))
  ltf_avgsnr_dB = ltf_avgsnr_dB
  data_constellation_avgsnr_dB_overestimate = data_constellation_avgsnr_dB_overestimate

  %%***************************************
  %% update statistics
  %%***************************************
  stats = updateStats(data, opt, stats, uu_ltf1, uu_ltf2, ch);

  %display('Press any key to continue...')
  %pause
  if (filter_match)
    display('data processed for filter-matching pkt. continue?')
    pause
  end
end


%------------------------------------------------------------------------------------
function stats = updateStats(data, opt, stats, uu_ltf1, uu_ltf2, ch)
%------------------------------------------------------------------------------------
  if (data.frame_type == opt.ftype.data)
    stats.ber_vec_data(end+1) = data.ber;
    stats.crc_vec_data(end+1) = data.crcValid;
    stats.seq_vec_data(end+1,:) = data.seq;

    %stats.ltf_sync_freq_domain = ltf_sync_freq_domain;
    stats.uu_ltf1_data(:,end+1) = uu_ltf1;
    stats.uu_ltf2_data(:,end+1) = uu_ltf2;
    stats.ch_data(:,end+1) = ch;
  elseif (data.frame_type == opt.ftype.ack)
    stats.ber_vec_ack(end+1) = data.ber;
    stats.crc_vec_ack(end+1) = data.crcValid;
    stats.seq_vec_ack(end+1,:) = data.seq;

    stats.uu_ltf1_ack(:,end+1) = uu_ltf1;
    stats.uu_ltf2_ack(:,end+1) = uu_ltf2;
    stats.ch_ack(:,end+1) = ch;
  elseif (data.frame_type == opt.ftype.unknown)
    stats.ber_vec_unknown(end+1) = data.ber;
    stats.crc_vec_unknown(end+1) = data.crcValid;
    stats.seq_vec_unknown(end+1,:) = data.seq;

    stats.uu_ltf1_unknown(:,end+1) = uu_ltf1;
    stats.uu_ltf2_unknown(:,end+1) = uu_ltf2;
    stats.ch_unknown(:,end+1) = ch;
  end
end




