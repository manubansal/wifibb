
%>> [constpoints, n_constpoints] = load_samples('/home/manub/workspace/orsys/app/wifi54/trace/debug/d54mOfdmEq.bho0.bufOutEqualizedPnts.ORILIB_t_Cplx16Buf48.dat', 'cplx');
%>> rx_constellation_stream(constpoints)
% payload_len is in number of bytes

function wifi_rx_constellation_stream(samples, payload_len)
  [DATA_DIR, TRACE_DIR, CDATA_DIR, BDATA_DIR] = setup_paths()
  %path = sprintf('%s/%s*', BDATA_DIR, confStr)

  %samples(1:1000,:)
  n_samples = length(samples)


  %%%%%%%%%%%%%%%%%%%%%%
  %% decode messages
  %%%%%%%%%%%%%%%%%%%%%%
  %td_pkt_samples_16bit = samples(1:20000000);
  td_pkt_samples_16bit = samples;
  %confStr = 'fromair.rate54'
  confStr = 'siggen.rate54.neg53const'

  num_strs = regexp(confStr, '\d+', 'match');
  rate = str2double(num_strs(1));

  rx_pkts = wifi_rx_pkt_constellation_train(td_pkt_samples_16bit, confStr, rate, payload_len);
end
