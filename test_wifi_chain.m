function test_wifi_chain(tag, snr, msglen, rate, nmsgs)
  tx_params = wifi_tx_parameters();

  if nargin < 1
    tag = 'mytag';
  end

  if nargin < 2
    snr = Inf;
  end

  if nargin < 3
    msglen = 200;	%bytes
  end

  if nargin < 4
    rate = 54;
    %rate = 36;
    %rate = 24;
    %rate = 6;

    %snr = 30;
    %snr = 35;
    %snr = 30;
    %snr = 17; 	
  end

  if nargin < 5
    nmsgs = 1;
  end


  %test1(rate, snr)
  test2(tag, rate, snr, msglen, nmsgs, tx_params)
end

function test2(tag, rate, snr, msglen, nmsgs, tx_params)
  scale = sqrt(2);

  %%%%%%%%%%%%%%%%%%%%%%
  %% pick the message(s)
  %%%%%%%%%%%%%%%%%%%%%%
  msgs_hex = util_msg_hex(msglen);
  n_msgs = length(msgs_hex);
  if n_msgs ~= 1
    warning('using only the first msg')
  end
  msgs_hex = msgs_hex(1);
  msgs_hex = repmat(msgs_hex, 1, nmsgs)


  %%%%%%%%%%%%%%%%%%%%%%
  %% conf string
  %%%%%%%%%%%%%%%%%%%%%%
  %confStr = sprintf('rate%d.snr%d.nmsgs%d.scale%04.2f', rate, snr, n_msgs, scale)
  confStr = sprintf('%s.rate%d.snr%d.nmsgs%d.msglen%d.scale%04.2f', tag, rate, snr, n_msgs, msglen, scale)

  %%%%%%%%%%%%%%%%%%%%%%
  %% remove old files
  %%%%%%%%%%%%%%%%%%%%%%
  [DATA_DIR, TRACE_DIR, CDATA_DIR, BDATA_DIR] = setup_paths()
  path = sprintf('%s/%s*', BDATA_DIR, confStr);
  fprintf(1, 'Deleting %s, press any key...\n', path)
  delete(path)
  %pause

  %%%%%%%%%%%%%%%%%%%%%%
  %% modulate messages
  %%%%%%%%%%%%%%%%%%%%%%
  [td_pkt_samples_16bit msgs_scr] = wifi_tx_pkt_train(msgs_hex, rate, snr, scale, confStr);
  n_tx_samples = length(td_pkt_samples_16bit)

  %pause
  %msgs_hex, rate, snr, scale = wifi_rx_pkt_train(td_pkt_samples_16bit)

  %%%%%%%%%%%%%%%%%%%%%%
  %% write samples
  %%%%%%%%%%%%%%%%%%%%%%
  if tx_params.writeSamples
    util_writeSamples(td_pkt_samples_16bit, confStr)
  end

  %%%%%%%%%%%%%%%%%%%%%%
  %% decode messages
  %%%%%%%%%%%%%%%%%%%%%%
  rx_pkts = wifi_rx_pkt_train(td_pkt_samples_16bit, confStr);

  %%%%%%%%%%%%%%%%%%%%%%
  %% detailed comparison
  %%%%%%%%%%%%%%%%%%%%%%
  if tx_params.compare_tx_rx_pkts
    util_compare_tx_rx_pkts(msgs_hex, rx_pkts, msgs_scr)
  end
end

function test1(rate, snr)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% pick a rate
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% pick other settings
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  softbit_scale_nbits = 6;	%soft-bit scale
  %softbit_scale_nbits = 8;	%soft-bit scale
  tblen = 36;
  %tblen = 72;

  
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

  rx_samples_f = wifi_awgn(samples_f, snr);
  %rx_samples_f = samples_f;

  %--------------------------------------------------------------------------
  rx_data_field = wifi_rx_chain_simple(rx_samples_f, rate, n_ofdm_syms, base_msg_len_bits, softbit_scale_nbits, tblen);
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

