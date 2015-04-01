%function test_wifi_chain(tag, snr, msglen, rate, nmsgs, ch, cplen)
function test_wifi_chain(sim_params, tx_params, rx_params, common_params, tag, snr, msglen, rate, nmsgs, ch, cplen)
  %df = sprintf('diary.test_wifi_chain.%s.%d.%d.%d.%d', tag, snr, msglen, rate, nmsgs)
  %diary(df);
  %df = df
  
  CURR_DIR = pwd;    
  if nargin < 1
      cd(strcat(getenv('PARAMS_DIR'), '/wifi64'));
      sim_params = default_sim_parameters();
      cd(CURR_DIR);
  end
  
  if nargin < 2
      cd(strcat(getenv('PARAMS_DIR'), '/wifi64'));
      tx_params = wifi_tx_parameters();
      cd(CURR_DIR);
  end

  if nargin < 3
      cd(strcat(getenv('PARAMS_DIR'), '/wifi64'));
      rx_params = wifi_rx_parameters();
      cd(CURR_DIR);
  end

  if nargin < 4
      cd(strcat(getenv('PARAMS_DIR'), '/wifi64'));
      common_params = wifi_common_parameters({});
      cd(CURR_DIR);
  end

  if nargin < 5
    tag = sim_params.tag;
  end

  if nargin < 6
%     snr = Inf;
    snr = sim_params.snr;
  end

  if nargin < 7
%     msglen = 200;	%bytes
    msglen = sim_params.msglen; % bytes
  end

  if nargin < 8
    rate = sim_params.rate;
    %rate = 36;
    %rate = 24;
    %rate = 6;

    %snr = 30;
    %snr = 35;
    %snr = 30;
    %snr = 17; 	
  end

  if nargin < 9
    nmsgs = sim_params.nmsgs;
  end

  if nargin < 10
    ch = sim_params.ch;
  end

  if nargin < 11
    cplen = common_params.cplen;
  end

  %do_test_old(rate, snr)
  do_test(sim_params, tx_params, rx_params, common_params, tag, rate, snr, msglen, nmsgs, tx_params, ch, cplen)
end

function do_test(smp, txp, rxp, cmp, tag, rate, snr, msglen, nmsgs, tx_params, ch, cplen)
  %scale = sqrt(2);
  %scale = 2;
  scale = tx_params.scale;

  %%%%%%%%%%%%%%%%%%%%%%
  %% pick the message(s)
  %%%%%%%%%%%%%%%%%%%%%%
  msgs_hex = util_msg_hex(msglen);
  n_msgs = length(msgs_hex); 
  if n_msgs ~= 1
    warning('using only the first msg')
  end
  msgs_hex = msgs_hex(1);
  msgs_hex = repmat(msgs_hex, 1, nmsgs);
  n_msgs = nmsgs;


  %%%%%%%%%%%%%%%%%%%%%%
  %% conf string
  %%%%%%%%%%%%%%%%%%%%%%
  %confStr = sprintf('rate%d.snr%d.nmsgs%d.scale%04.2f', rate, snr, n_msgs, scale)
  confStr = sprintf('%s.rate%d.snr%d.nmsgs%d.msglen%d.scale%04.2f', tag, round(rate*1000), snr, n_msgs, msglen, scale)


  %%%%%%%%%%%%%%%%%%%%%%
  %% remove old files
  %%%%%%%%%%%%%%%%%%%%%%
  [DATA_DIR, TRACE_DIR, CDATA_DIR, BDATA_DIR] = setup_paths()
  path = sprintf('%s/%s*', BDATA_DIR, confStr);
  %fprintf(1, 'Deleting %s, press any key...\n', path)
  fprintf(1, 'Deleting %s...\n', path)
  delete(path)
  %pause

  diaryFile = sprintf('%s/%s.diary.txt', BDATA_DIR, confStr);
  diary('off');
  diary(diaryFile);

  %%%%%%%%%%%%%%%%%%%%%%
  %% modulate messages
  %%%%%%%%%%%%%%%%%%%%%%
  [td_pkt_samples_16bit msgs_scr] = wifi_tx_pkt_train(smp, txp, cmp, msgs_hex, rate, snr, scale, confStr, ch, cplen);
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
  rx_pkts = wifi_rx_pkt_train(smp, cmp, rxp, td_pkt_samples_16bit, confStr, cplen);

  %%%%%%%%%%%%%%%%%%%%%%
  %% detailed comparison
  %%%%%%%%%%%%%%%%%%%%%%
  if tx_params.compare_tx_rx_pkts
    util_compare_tx_rx_pkts(msgs_hex, rx_pkts, msgs_scr)
  end

  diary('off')

end
