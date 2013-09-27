function test_wifi_vdec()
  test1()
end


function test1()
  rate_v = [6, 9, 12, 18, 24, 36, 48, 54];

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% pick a rate
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %rate = 54;
  rate = 36;
  %rate = 24;
  %rate = 6;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% pick other settings
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  nbits = 6;	%soft-bit scale
  %nbits = 8;	%soft-bit scale
  tblen = 36;
  %tblen = 72;

  %snr = 30;
  snr = 17; 	
  
  %54mbps
  %snr 15	16	17	18
  %ber 0.1412 	0.0275	0	0

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% pick the message
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  msg_hex = [
  '04'; '02'; '00'; '2e'; '00'; '60'; '08'; 'cd'; '37'; 'a6'; '00'; '20'; 'd6'; '01'; '3c'; 'f1'; '00'; '60'; '08'; 'ad'; '3b'; 'af'; '00'; '00'; '4a'; '6f'; '79'; '2c'; '20'; '62'; '72'; '69'; '67'; '68'; '74'; '20'; '73'; '70'; '61'; '72'; '6b'; '20'; '6f'; '66'; '20'; '64'; '69'; '76'; '69'; '6e'; '69'; '74'; '79'; '2c'; '0a'; '44'; '61'; '75'; '67'; '68'; '74'; '65'; '72'; '20'; '6f'; '66'; '20'; '45'; '6c'; '79'; '73'; '69'; '75'; '6d'; '2c'; '0a'; '46'; '69'; '72'; '65'; '2d'; '69'; '6e'; '73'; '69'; '72'; '65'; '64'; '20'; '77'; '65'; '20'; '74'; '72'; '65'; '61'; 'da'; '57'; '99'; 'ed']

  msg_dec = hex2dec(msg_hex);
  %msg_dec = msg_dec(1:15)
  %pause

  msg = dec2bin(msg_dec, 8);
  msg = fliplr(msg);	%lsb msb flip
  msg = msg';
  msg = reshape(msg, prod(size(msg)), 1);
  msg = str2num(msg);
  base_msg = msg;

  %msg_len = 500;
  %msg = randint(msg_len,1);

  base_msg_len_bits = length(base_msg);
  scale = 2^nbits - 1;

  ndbps_v = [24, 36, 48, 72, 96, 144, 192, 216];
  ncbps_v = [48, 48, 96, 96, 192, 192, 288, 288];
  nbpsc_v = [1, 1, 2, 2, 4, 4, 6, 6];
  rt120_v = [60, 90, 60, 90, 60, 90, 80, 90];

  ri = find(rate_v == rate);
  ndbps = ndbps_v(ri);
  ncbps = ncbps_v(ri);
  nbpsc = nbpsc_v(ri);
  rt120 = rt120_v(ri);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% prepare the message with service, tail and pad bits
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  service = zeros(16,1);
  tail = zeros(6,1);
  msg = [service; msg; tail];

  npad = ceil(length(msg)/ndbps) * ndbps - length(msg);
  pad = zeros(npad,1);
  msg = [msg; pad];

  n_ofdm_syms = length(msg)/ndbps

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% scramble the message
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  src_initstate = [1 0 1 1 1 0 1];
  [msg_scr scr_seq] = wifi_scramble(msg, src_initstate);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% zero-out tail portion after scrambling
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  msg_scr(16 + base_msg_len_bits + 1:16 + base_msg_len_bits + 6) = 0;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% code the entire message (with service, tail and pad) and also
  %% puncture it according to the coding rate
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  msg_code = wifi_cenc(msg_scr, rt120);
  %coded_message_soft_bits = coded_message * scale;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% arrange coded bits as symbols
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  msg_code_syms = reshape(msg_code, ncbps, n_ofdm_syms);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% interleave the bits
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  msg_int_syms = wifi_interleave(msg_code_syms, ncbps);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% map bits onto constellation symbols
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  mapped_syms = [];
  for i = 1:n_ofdm_syms
    mapped_syms = [mapped_syms wifi_map(msg_int_syms(:,i), nbpsc)];
  end
  samples_f = reshape(mapped_syms, prod(size(mapped_syms)), 1);

  %--------------------------------------------------------------------------

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% let's add some AWGN noise
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

  rx_samples_f = awgn(samples_f, snr, 'measured');
  %rx_samples_f = samples_f;

  %--------------------------------------------------------------------------

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% demap symbols
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %function softbits = wifi_softSlice(points, nbpsc, nbits, range)
  rx_syms = reshape(rx_samples_f, length(rx_samples_f)/n_ofdm_syms, n_ofdm_syms);
  rx_syms_softbits = [];
  for i = 1:n_ofdm_syms
    rx_syms_softbits = [rx_syms_softbits wifi_softSlice(rx_syms(:,i), nbpsc, nbits)];
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% deinterleave softbits
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  t = wifi_deinterleaveTables();
  rx_syms_deint = wifi_deinterleave(t, rx_syms_softbits, nbpsc);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% depuncture softbits
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  rx_softbits_deint = reshape(rx_syms_deint, prod(size(rx_syms_deint)), 1);
  rx_softbits_depunc = wifi_softDepuncture(rx_softbits_deint, nbits, rt120);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% decode softbits
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %discard pad bits
  n_bits_to_keep = (base_msg_len_bits + 16 + 6) * 2;
  rx_softbits_depunc = rx_softbits_depunc(1:n_bits_to_keep);
  %function [ dmsg ] = wifi_vdec(incode, nbits, tblen, initmetric, initstates, initinputs)
  rx_decoded_bits = wifi_vdec(rx_softbits_depunc, nbits, tblen);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% descramble bits
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  [rx_descrambled_bits descr_seq] = wifi_descramble(rx_decoded_bits);
  
  rx_service_field = rx_descrambled_bits(1:16);
  rx_data_field = rx_descrambled_bits(16+1:16+base_msg_len_bits);
  rx_tail_field = rx_descrambled_bits(16+base_msg_len_bits+1:end);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% calculate ber
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %[rx_data_field base_msg]
  %base_msg
  %whos
  %pause
  length(base_msg)
  size(descr_seq)
  whos
  scr_seq_no_pad = scr_seq(1:(16 + length(base_msg) + 6));
  [(1:length(descr_seq))' scr_seq_no_pad descr_seq]
  %pause
  [(1:length(base_msg))' rx_data_field base_msg rx_data_field - base_msg]
  rx_service_field = rx_service_field
  rx_tail_field = rx_tail_field
  n_bit_err = sum(abs(rx_data_field - base_msg));
  ber = n_bit_err/base_msg_len_bits
  %pause


  %-------------------------

  %msg_scr_no_pad = msg_scr(1:(16 + base_msg_len_bits + 6));
  %[msg_scr_no_pad rx_decoded_bits msg_scr_no_pad - rx_decoded_bits]
  %n_bit_err_scr = sum(abs(msg_scr_no_pad - rx_decoded_bits))
end
