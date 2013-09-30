function test_wifi_chain()
  test1()
end

function test1()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% pick a rate
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  rate = 54;
  %rate = 36;
  %rate = 24;
  %rate = 6;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% pick other settings
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  softbit_scale_nbits = 6;	%soft-bit scale
  %softbit_scale_nbits = 8;	%soft-bit scale
  tblen = 36;
  %tblen = 72;

  snr = 30;
  %snr = 17; 	
  
  %54mbps
  %snr 15	16	17	18
  %ber 0.1412 	0.0275	0	0

  scale = 2^softbit_scale_nbits - 1;

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

  %msg_len = 500;
  %msg = randint(msg_len,1);

  base_msg = msg;
  base_msg_len_bits = length(base_msg);

  %--------------------------------------------------------------------------
  [samples_f, n_ofdm_syms] = wifi_tx_chain(msg, rate);
  %--------------------------------------------------------------------------

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% let's add some AWGN noise
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

  rx_samples_f = awgn(samples_f, snr, 'measured');
  %rx_samples_f = samples_f;

  %--------------------------------------------------------------------------
  rx_data_field = wifi_rx_chain(rx_samples_f, rate, n_ofdm_syms, base_msg_len_bits, softbit_scale_nbits, tblen);
  %--------------------------------------------------------------------------

  [(1:length(base_msg))' rx_data_field base_msg rx_data_field - base_msg]

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% calculate ber
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  n_bit_err = sum(abs(rx_data_field - base_msg));
  ber = n_bit_err/base_msg_len_bits

  %-------------------------
  %msg_scr_no_pad = msg_scr(1:(16 + base_msg_len_bits + 6));
  %[msg_scr_no_pad rx_decoded_bits msg_scr_no_pad - rx_decoded_bits]
  %n_bit_err_scr = sum(abs(msg_scr_no_pad - rx_decoded_bits))
end
