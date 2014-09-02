%------------------------------------------------------------------------------------
function [stats parsed_data frame_type crcValid rx_data_bits_dec] = ...
wifi_rx_chain_constellation(pkt_samples, rate, payload_len, data, opt, stats, confStr)
%------------------------------------------------------------------------------------
  %rx_sig_field = wifi_pack_signal(rate, payload_len);
  %[t_rate t_len modu t_code t_parityCheck t_valid t_ndbps t_nsyms] = wifi_parse_signal(rx_sig_field)
  %pause


  stf_len = opt.stf_len;
  ltf_len = opt.ltf_len;
  sig_len = opt.sig_len;

  data_samples = pkt_samples(1:end);

  if (opt.dumpVars_dataBaseSamples)
    util_dumpData('dataBaseSamples', confStr, data_samples)
  end

  stats.n_packets_processed = stats.n_packets_processed + 1;

  %%*********************************
  %%%%%% decide whether to process data field
  %%*********************************

  [ndbps, rt120, ncbps, nbpsc, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameters(rate);
  n_cplx_samples_per_pkt = length(pkt_samples);
  nsyms = n_cplx_samples_per_pkt/48

  coderate = rt120;


  %filter_match = data.sig_rate == 54 && data.sig_payload_length == 1475;
  %filter_match = data.sig_rate == 54 && data.sig_payload_length == 1514;
  %filter_match = data.sig_rate == 54 && data.sig_payload_length == 15;
  filter_match = true;


  %%*********************************
  %%%%%% process data field
  %%*********************************

  %rx_data_syms(:,1)=[];
  %rx_data_syms = rx_data_syms(:,1:nsyms);
  rx_data_syms = reshape(pkt_samples, 48, []);
  size(rx_data_syms)
  pause

  %NOTE: the following can be very inaccurate. ltf SNR is a much better estimate.
  [avgsnr avgsnr_dB snr_vector snr_vector_dB] = util_constellationSNR(rx_data_syms, nbpsc);
  avgsnr_dB_from_data_constellation_evm = avgsnr_dB

  % plot the constellation for data part
  if (~opt.GENERATE_PER_PACKET_PLOTS_ONLY_ON_FILTER_MATCH || filter_match)
    if (opt.GENERATE_PER_PACKET_PLOTS && opt.GENERATE_PER_PACKET_PLOTS_CONSTELLATION)
      util_plotConstellation(rx_data_syms, ...
	  opt.figure_handle_perpkt, opt.subplot_handles_constellation);
    end
  end

  [rx_data_bits]  		= wifi_wrapper_demap_packet(rx_data_syms, nsyms, nbpsc, opt.soft_slice_nbits);

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
  data_and_tail_length_bits = 16 + payload_len * 8 + 6;	%first 16 for service, last 6 for tail
  actual_data_portion_with_tail = rx_data_bits_depunct(1:(data_and_tail_length_bits * 2));	%since it's a half rate code

  [rx_data_bits_dec]         = wifi_wrapper_decode(actual_data_portion_with_tail, 16 + payload_len * 8, opt);
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
  rx_data_bits_descr = rx_data_bits_descr(1:(16+ payload_len * 8));
  rx_data_bytes = reshape(rx_data_bits_descr, 8, payload_len + 2);
  size_rx_data_bytes = size(rx_data_bytes);

  %++++++++++++++++++++++++++++++++++++++++++++++
  if (opt.dumpVars_dataDescr)
    util_dumpData('dataDescr', confStr, rx_data_bits_descr)
  end
  %++++++++++++++++++++++++++++++++++++++++++++++



  [parsed_data frame_type ber crcValid] = wifi_parse_payload(rx_data_bytes);
  data.parsed_data = parsed_data;
  data.frame_type = frame_type;
  data.ber = ber;
  data.crcValid = crcValid;

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
  display('------------------------------------------------------------');
  display('parse data results: ');
  display(strcat('frame_type (0: data, 1: ack, 2: unknown):', num2str(frame_type), ...
    ' ber:', num2str(ber), ' crcValid:', num2str(crcValid)));
  display('------------------------------------------------------------');

  avgsnr_dB_from_data_constellation_evm = avgsnr_dB_from_data_constellation_evm

  %%***************************************
  %% update statistics
  %%***************************************
  stats = updateStats(data, opt, stats);
  stats.avgsnr_dB_from_evm(end+1) = avgsnr_dB_from_data_constellation_evm;

  %display('Press any key to continue...')
  %pause
  if (filter_match)
    display('data processed for filter-matching pkt. continue?')
    pause
  end
end



%------------------------------------------------------------------------------------
function stats = updateStats(data, opt, stats)
%------------------------------------------------------------------------------------
  display('updating stats');
  if (data.frame_type == opt.ftype.data)
    display('frame type: data')
    stats.ber_vec_data(end+1) = data.ber;
    stats.crc_vec_data(end+1) = data.crcValid;
  elseif (data.frame_type == opt.ftype.ack)
    display('frame type: ack')
    stats.ber_vec_ack(end+1) = data.ber;
    stats.crc_vec_ack(end+1) = data.crcValid;
  elseif (data.frame_type == opt.ftype.unknown)
    display('frame type: unknown')
    stats.ber_vec_unknown(end+1) = data.ber;
    stats.crc_vec_unknown(end+1) = data.crcValid;
  end
end
