%function stats = wifi_rx_chain(samples, scale, mod, opt)
%----------------------------------------------------------------------------------------------------------------------------
%function stats = analyzeSinglePacket(data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
function stats = wifi_rx_chain(data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------

  %n_p_d = stats.n_packets_processed
  [stats data] 				= wifi_cleanup_packet(data, opt, stats);

  if (~data.cleanupDone)
    display('wifi_cleanup_packet failed');
    return;
  end
  %n_p_d = stats.n_packets_processed
  stats.n_packets_processed = stats.n_packets_processed + 1;
  %n_p_d = stats.n_packets_processed

  %%********************************
  %%%%%%%%% process signal field
  %%********************************

  nbpsc = 1;	%signal field is coded with bpsk
  nsyms = 1;	%signal field occupies one ofdm symbol

  [stats data ofdm_syms_f]  		= wifi_ofdm_demod(data.sig_samples, nsyms, data, opt, stats);

  %++++++++++++++++++++++++++++++++++++++++++++++
  [ig1, ig2, ig3, ig4, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameters(0)
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

  if (opt.dumpVars_ofdmDemodPlcp)
    util_dumpData('ofdmDemodPlcp', fix(opt.ti_factor_after_cfo * ofdm_syms_f(dsubc_idx, 1)))
  else
    display('not dumping')
  end
  if (opt.PAUSE_AFTER_EVERY_PACKET)
    pause
  end
  %++++++++++++++++++++++++++++++++++++++++++++++

  [stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] ...
  					= wifi_channel_correction(nsyms, opt, data, stats, ofdm_syms_f);

  [stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] ...
  					= wifi_pilot_phase_tracking(stats, data, opt, ofdm_syms_f, uu_pilot_syms, nsyms);

  [stats data rx_data_syms rx_pilot_syms uu_pilot_syms ofdm_syms_f] ...
  					= wifi_pilot_sampling_delay_correction(stats, data, opt, ofdm_syms_f, uu_pilot_syms, nsyms);

  [stats data] 				= util_generate_constellation_plots(stats, data, opt, uu_pilot_syms);


  [stats data rx_data_bits]  		= demapPacket(rx_data_syms, nsyms, nbpsc, data, opt, stats);

  util_print_demapPacket_plcp(rx_data_syms, opt);

  %display('after demapping:');
  %rx_data_bits
  %pause

  [stats ber]   	     		= util_computeModulationBER(data, opt, stats);
  [stats data rx_data_bits_deint]       = deinterleave(data, opt, stats, rx_data_bits, nbpsc);

  %display('after deinterleave:');
  %rx_data_bits_deint
  %pause

  [stats data rx_data_bits_dec]         = decode(data, opt, stats, rx_data_bits_deint, opt.tblen_signal);

  %display('signal field after decode:');
  %rx_data_bits_dec
  %pause

  [stats data]				= parse_signal(data, opt, stats, rx_data_bits_dec);

  if (~data.sig_valid)
    return
  end


  %%*********************************
  %%%%%% process data field
  %%*********************************

  nbpsc = data.sig_modu;
  nsyms = data.sig_nsyms;
  coderate = data.sig_code;

  [stats data ofdm_syms_f]  		= wifi_ofdm_demod([data.sig_samples data.data_samples], nsyms+ 1, data, opt, stats);

  [stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] = wifi_channel_correction(nsyms + 1, opt, data, stats, ofdm_syms_f);
  [stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] = wifi_pilot_phase_tracking(stats, data, opt, ofdm_syms_f, uu_pilot_syms, nsyms + 1);
  [stats data rx_data_syms rx_pilot_syms uu_pilot_syms ofdm_syms_f] = ...
	wifi_pilot_sampling_delay_correction(stats, data, opt, ofdm_syms_f, uu_pilot_syms, nsyms + 1);
  [stats data] = util_generate_constellation_plots(stats, data, opt, uu_pilot_syms);




  rx_data_syms(:,1)=[];
  rx_data_syms = rx_data_syms(:,1:nsyms);

  if (opt.printVars_equalize)
    util_print_equalize(rx_data_syms);
    if (opt.PAUSE_AFTER_EVERY_PACKET)
	    pause
    end
  end

  %display('size of rx_data_syms before demapping:');
  %size(rx_data_syms)

  %rx_data_syms = reshape(rx_data_syms, prod(size(rx_data_syms)), 1);
  [stats data rx_data_bits]  		= demapPacket(rx_data_syms, data.sig_nsyms, data.sig_modu, data, opt, stats);

  util_print_demapPacket_data(rx_data_bits, opt);

  %[stats ber]   	     		= util_computeModulationBER(data, opt, stats);
  [stats data rx_data_bits_deint]  	= deinterleave(data, opt, stats, rx_data_bits, nbpsc);

  if (opt.printVars_deinterleave)
	  util_print_deinterleave(rx_data_bits_deint);
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
		  pause
	  end
  end

  %display('after deinterleave:');
  %rx_data_bits_deint
  %pause

  rx_data_bits_deint = reshape(rx_data_bits_deint, prod(size(rx_data_bits_deint)), 1);
  [stats data rx_data_bits_depunct]     = depuncture(data, opt, stats, rx_data_bits_deint, coderate);

  %display('after depuncture');
  %rx_data_bits_depunct
  %pause

  %decode the actual data length portion
  data_and_tail_length_bits = 16 + data.sig_payload_length * 8 + 6;	%first 16 for service, last 6 for tail
  actual_data_portion_with_tail = rx_data_bits_depunct(1:(data_and_tail_length_bits * 2));	%since it's a half rate code

  [stats data rx_data_bits_dec]         = decode(data, opt, stats, rx_data_bits_depunct, opt.tblen_data);

  %display('data field after decode (including service field):');
  %rx_data_bits_dec
  %pause

  if (opt.printVars_decodedBits)
	  util_print_decode(rx_data_bits_dec, data.sig_ndbps, opt.n_decoded_symbols_per_ofdm_symbol);
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
		  pause
	  end
  end


  %display('scrambled service field:');
  %rx_data_bits_dec(1:16)
  %pause

  %remove tail
  %rx_data_bits_dec = rx_data_bits_dec(1:end-6);

  [rx_data_bits_descr]			= descramble(rx_data_bits_dec);

  if (opt.printVars_descrambledBits)
	  util_print_descramble(rx_data_bits_descr, data.sig_ndbps);
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
		  pause
	  end
  end

  %display('data field after decode and descramble (including service field) arranged as bytes:');
  rx_data_bytes = reshape(rx_data_bits_descr, 8, length(rx_data_bits_descr)/8);

  %retain only upto the data portion, including service field but discarding tail and pad
  rx_data_bits_descr = rx_data_bits_descr(1:(16+data.sig_payload_length * 8));
  rx_data_bytes = reshape(rx_data_bits_descr, 8, data.sig_payload_length + 2);
  size_rx_data_bytes = size(rx_data_bytes);

  %pause

  %[parsed_data data]			= parse_payload(rx_data_bytes, data);
  [data.parsed_data data.frame_type data.ber data.crcValid] = parse_payload(rx_data_bytes);

  %display('data bits arranged as bytes (excluding service)');
  %rx_data_bytes(:,3:end)

  %size_parsed_data = size(parsed_data)
  %display('hex data bytes');
  %[(1:data.sig_payload_length)' parsed_data]
  %parsed_data
  util_printHexOctets(data.parsed_data);

  %%***************************************
  %% display plcp intermediaries/results
  %%***************************************


  display('------------------------------------------------------------');
  display('parse data results: ');
  display(strcat('frame_type (0: data, 1: ack, 2: unknown):', num2str(data.frame_type), ...
    ' ber:', num2str(data.ber), ' crcValid:', num2str(data.crcValid)));
  display('------------------------------------------------------------');


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
  %%***************************************
  %function stats = updateStats(data, stats)
  stats = updateStats(data, opt, stats);


end



%----------------------------------------------------------------------------------------------------------------------------
function [stats data rx_data_bits] = demapPacket_old(rx_data_syms, data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------

  %rx_data_syms = data.rx_data_syms;

  if (prod(size(rx_data_syms)) == 0)
    return;
  end
  %stats.n_packets_processed = stats.n_packets_processed + 1;

  util_plotConstellation(rx_data_syms, opt);

  %hard-demap symbols to bits according to bpsk
  rx_data_syms_i = real(rx_data_syms);
  rx_data_bits_i = sign(rx_data_syms_i);	%contains 1, -1 and 0
  rx_data_bits_i = fix((rx_data_bits_i + 1)/2);	%contains 1 and 0 only

  %data.rx_data_bits_i = rx_data_bits_i;
  %data.rx_data_bits_q = rx_data_bits_q;
  %data.rx_data_bits_q = rx_data_bits_i;

  %[this_ndsubc this_nsyms] = size(rx_data_bits_i);
  %this_ndsubc_2 = (1:this_ndsubc)*2;
  %rx_data_bits(this_ndsubc_2 - 1, :) = data.rx_data_bits_i;
  %rx_data_bits(this_ndsubc_2, :) = data.rx_data_bits_q;
  rx_data_bits = rx_data_bits_i;
  rx_data_bits = rx_data_bits * 255;	%making bits soft
end

%----------------------------------------------------------------------------------------------------------------------------
function [stats data rx_data_bits] = demapPacket(rx_data_syms, nsyms, nbpsc, data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  if (prod(size(rx_data_syms)) == 0)
    return;
  end
  %stats.n_packets_processed = stats.n_packets_processed + 1;

  util_plotConstellation(rx_data_syms, opt);

  %rx_data_syms = reshape(rx_data_syms, prod(size(rx_data_syms)), 1);
  rx_data_bits = wifi_softSlice(rx_data_syms, nbpsc, opt.soft_slice_nbits);
end

%----------------------------------------------------------------------------------------------------------------------------
function [stats data rx_data_bits_deint] = deinterleave(data, opt, stats, rx_data_bits, nbpsc)
%----------------------------------------------------------------------------------------------------------------------------
  t = data.deinterleave_tables;
  %size(rx_data_bits)
  rx_data_bits_deint = wifi_deinterleave(t, rx_data_bits, nbpsc);
  %size(rx_data_bits_deint)

  if (opt.writeVars_deinterleave)
  writeVars_deinterleave(rx_data_bits, rx_data_bits_deint);
  end

  %%%%%%%%%%%%%%%%%%%%%%%
    if (opt.printVars_softBits_deint)
	  display('plcp signal field soft bits after deinterleaving');
	  nbits = opt.soft_slice_nbits;
	  scale = 2^(nbits - 1);		%for 8 bits, this is 128, so that we can contain the soft estimates in [-128, 128]
	  size(rx_data_bits_deint)
	  size(scale)
	  %[[1:length(rx_data_bits)]' (rx_data_bits - scale)]	%representing in [-scale, scale], instead of [0, 2*scale]
	  [[1:size(rx_data_bits_deint,1)]' (rx_data_bits_deint(:,1) - scale)]	%representing in [-scale, scale], instead of [0, 2*scale]
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
	    pause
	  end
    end
  %%%%%%%%%%%%%%%%%%%%%%%

end


%----------------------------------------------------------------------------------------------------------------------------
function [stats data rx_data_bits_depunct] = depuncture(data, opt, stats, rx_data_bits_deint, coderate)
%----------------------------------------------------------------------------------------------------------------------------
  rx_data_bits_depunct = wifi_softDepuncture(rx_data_bits_deint, opt.soft_slice_nbits, coderate);
  if (opt.writeVars_depuncture)
  writeVars_depuncture(rx_data_bits_deint, opt.soft_slice_nbits, coderate, rx_data_bits_depunct);
  end
end

%----------------------------------------------------------------------------------------------------------------------------
function [stats data rx_data_bits_dec] = decode(data, opt, stats, rx_data_bits_depunct, tblen)
%----------------------------------------------------------------------------------------------------------------------------
  rx_data_bits_dec = wifi_vdec(rx_data_bits_depunct, opt.soft_slice_nbits, tblen);
  if (opt.writeVars_decode)
  writeVars_decode(rx_data_bits_depunct, opt.soft_slice_nbits, tblen, rx_data_bits_dec);
  end
end

%----------------------------------------------------------------------------------------------------------------------------
function [rx_data_bits_descr] = descramble(rx_data_bits_dec)
%----------------------------------------------------------------------------------------------------------------------------
  rx_data_bits_descr = wifi_descramble(rx_data_bits_dec);
end



%----------------------------------------------------------------------------------------------------------------------------
function [stats data rx_data_bits_dec ndbps nsyms] = parse_signal(data, opt, stats, rx_data_bits_dec)
%----------------------------------------------------------------------------------------------------------------------------
  [rate length modu code parityCheck valid ndbps nsyms] = wifi_parse_signal(rx_data_bits_dec);
  display('------------------------------------------------------------');
  display('parse signal results: ');
  display('data bits:');
  rx_data_bits_dec = rx_data_bits_dec
  display(strcat('rate: ', num2str(rate), ' length: ', num2str(length), ' code: ', num2str(code), ...
  	' parityCheck: ', num2str(parityCheck), ' valid: ', num2str(valid), ...
	' ndbps: ', num2str(ndbps), ' nsyms:', num2str(nsyms)));
  display('------------------------------------------------------------');
  data.sig_rate = rate;
  data.sig_payload_length = length;
  data.sig_modu = modu;
  data.sig_code = code;
  data.sig_parityCheck = parityCheck;
  data.sig_valid = valid;
  data.sig_ndbps = ndbps;
  data.sig_nsyms = nsyms;
end


%----------------------------------------------------------------------------------------------------------------------------
function [parsed_data frame_type ber crcValid] = parse_payload(databytes)	%each column is a byte, top of a byte being the earliest bit
  %display('service field:');
  service_field = databytes(:,1:2)

  databytes = databytes(:,3:end);

  %function [parsed_data frame_type ber crcValid] = wifi_parse_phy_payload(databytes)
  %[data.parsed_data data.frame_type data.ber data.crcValid] = wifi_parse_phy_payload(databytes);
  %%%%[parsed_data frame_type ber crcValid] = wifi_parse_phy_payload(databytes);


  %databytes = databytes

  m = 2.^(0:7)';	%oldest is lsb
  b = (diag(m) * databytes);
  databytes_dec = sum(b);
  databytes_hex = dec2hex(databytes_dec, 2);

  databytes_hex_with_crc32 = databytes_hex;
  %pause

  [crc_val crcValid] = wifi_crc32(databytes_hex_with_crc32);
  frame_type = 2; ber = -1;
  parsed_data = databytes_hex;
  %pause

end
%----------------------------------------------------------------------------------------------------------------------------



%----------------------------------------------------------------------------------------------------------------------------
function stats = updateStats(data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  if (data.frame_type == opt.ftype.data)
    stats.ber_vec_data(end+1) = data.ber;
    stats.crc_vec_data(end+1) = data.crcValid;

    %stats.ltf_sync_freq_domain = ltf_sync_freq_domain;
    stats.uu_ltf1_data(:,end+1) = data.uu_ltf1;
    stats.uu_ltf2_data(:,end+1) = data.uu_ltf2;
    stats.ch_data(:,end+1) = data.ch;
  elseif (data.frame_type == opt.ftype.ack)
    stats.ber_vec_ack(end+1) = data.ber;
    stats.crc_vec_ack(end+1) = data.crcValid;

    stats.uu_ltf1_ack(:,end+1) = data.uu_ltf1;
    stats.uu_ltf2_ack(:,end+1) = data.uu_ltf2;
    stats.ch_ack(:,end+1) = data.ch;
  elseif (data.frame_type == opt.ftype.unknown)
    stats.ber_vec_unknown(end+1) = data.ber;
    stats.crc_vec_unknown(end+1) = data.crcValid;

    stats.uu_ltf1_unknown(:,end+1) = data.uu_ltf1;
    stats.uu_ltf2_unknown(:,end+1) = data.uu_ltf2;
    stats.ch_unknown(:,end+1) = data.ch;
  end
end




