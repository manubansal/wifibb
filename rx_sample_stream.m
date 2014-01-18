
%>> [samples, n_samples] = load_samples('../wifibb-traces/traces54/usrp-1s.dat','cplx');
%>> rx_sample_stream(samples)

function rx_sample_stream(samples)
  [DATA_DIR, TRACE_DIR, CDATA_DIR, BDATA_DIR] = setup_paths()
  %path = sprintf('%s/%s*', BDATA_DIR, confStr)

  samples(1:1000,:)
  n_samples = length(samples)


  %%%%%%%%%%%%%%%%%%%%%%
  %% decode messages
  %%%%%%%%%%%%%%%%%%%%%%
  td_pkt_samples_16bit = samples(1:800000);
  confStr = 'fromair'
  rx_pkts = wifi_rx_pkt_train(td_pkt_samples_16bit, confStr);

end
