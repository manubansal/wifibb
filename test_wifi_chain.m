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


  %do_test_old(rate, snr)
  do_test(tag, rate, snr, msglen, nmsgs, tx_params)
end

function do_test(tag, rate, snr, msglen, nmsgs, tx_params)
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
  n_msgs = nmsgs;


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

  diaryFile = sprintf('%s/%s.diary.txt', BDATA_DIR, confStr);
  diary('off');
  diary(diaryFile);

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

  diary('off')

end
