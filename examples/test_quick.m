function test_quick(t)
  %quick_spectesting()
  %quick_per_vs_msglen()
  quick_cplentesting(t)
  %quick_cplentesting_pxb()
end

function quick_cplentesting(t)
 cd parambuilders
 dp = default_sim_parameters();
 tp = wifi_tx_parameters();
 rp = wifi_rx_parameters();
 cp = wifi_common_parameters();
 cd ..

  %cnrs = 25:3:60;
  %cnrs = 25:3:45;
  cnrs = [31:3:45];
  %cnrs = [18 22];
  %cnrs = 55;
  %cnrs = Inf;
  %cnrs = 50;
  %cnrs = 100;
  %cplens=[16,32,64];

  cplens=[16];
  %cplens=[32];

  %%%%ch = 't1000';
  %ch = 't100';
  %ch = 't50';
  %ch = 'f10';
  %ch = 'f100';
  %ch = 'f50';
  ch = 'f20';
  %ch = 'passthrough';
  nbytes = 1000;
  nmsgs = 500;
  %nmsgs = 200;
  %nmsgs = 50;
  %nmsgs = 10;
  %nmsgs = 3;
  %nmsgs = 1;
  %parfor cplen_idx = 1:length(cplens)
  %for cplen_idx = 1:length(cplens)
  for cplen_idx = t:t
    cplen = cplens(cplen_idx);
    lb = sprintf('cp%d%s', cplen, ch)
    for cnr = cnrs; 
      %test_wifi_chain(lb,cnr, nbytes, 54, nmsgs, ch, [cplen,cplen,cplen,cplen]); 
      test_wifi_chain(dp,tp,rp,cp,lb,cnr, nbytes, 54, nmsgs, ch, [cplen,cplen,cplen,cplen]); 
    end
  end
end

function quick_cplentesting_pxb()
  %f='~/tmp/floats_short'
  %f='~/tmp/cplentraces/floats_short'
  %f='~/tmp/cplentraces/floats_short'
  %f='~/tmp/cplentraces/floats_short_5_two_tap_35dB_tx_snr_cplen16'
  %f='~/tmp/cplentraces/floats_short7'
  f='~/workspace/wifibb-traces/cplentraces_pxb_usrp_20MHz/floats_short_7_two_tap_600ns_35dB_tx_snr_cplen32_wifibbsnr50'
  %f='~/tmp/cplentraces/floats_short8'
  %f='~/tmp/cplentraces/floats_short_8_two_tap_600ns_35dB_tx_snr_cplen16_wifibbsnr50'

  %f='~/tmp/cplentraces/floats_short_5_cplen32'

  %[samples, n_samples]=load_samples(f, 'cplx');
  [samples, n_samples]=load_samples(f, 'float32');
  n_samples = 20000;
  %n_samples = 100000;
  samples = samples(1:n_samples); 
  cplen = [16 16 16 16];
  %cplen = [32 32 32 32];
  rx_pkts=rx_sample_stream(samples, cplen);
  n_pkts = length(rx_pkts)
  %d8s = [];
  %for ii = 1 : n_pkts - 1
  %%for ii = 1 : 5
  %  rx_data_bytes = rx_pkts{ii}{5};
  %  [parsed_data frame_type ber crcValid] = wifi_parse_payload(rx_data_bytes);
  %  if prod(size(parsed_data)) > 0
  %    d8 = parsed_data(9:16,:)';
  %    d8 = d8(:);
  %    d8 = d8';
  %    d8s(end+1, :) = d8;
  %  else
  %    d8 = [];
  %  end
  %end
  %char(d8s)
end

function quick_spectesting()
  %f='/home/manub/workspace/wifibb-traces/traces54/seq-spectesting/signal_trace_spectesting_seq_-65dBmTX_-74dBmRX_skip0_ns500000.bin'
  f='/home/manub/workspace/wifibb-traces/traces54/txrx-spectesting/signal_trace_spectesting_-65dBmTX_-74dBmRX_skip0_ns500000.bin'
  [samples, n_samples]=load_samples(f, 'cplx');
  rx_pkts=rx_sample_stream(samples);
  n_pkts = length(rx_pkts)
  d8s = [];
  for ii = 1 : n_pkts - 1
  %for ii = 1 : 5
    rx_data_bytes = rx_pkts{ii}{5};
    [parsed_data frame_type ber crcValid] = wifi_parse_payload(rx_data_bytes);
    d8 = parsed_data(9:16,:)';
    d8 = d8(:);
    d8 = d8';
    d8s(end+1, :) = d8;
  end
  char(d8s)
end

function quick_per_vs_msglen()
  %snr = 16;
  %snr = 18;
  %snr = 20;
  %snr = 22;
  %rate = 54;
  %NPKTS = 100;

  NRUNS = 5;
  NPKTS = 10;

  for snr = 16:22
    for rate = [54 48 36]
      for msglen = 1500:-50:50
	for run = 1:NRUNS
	  display(['per_vs_msglen: snr = ' num2str(snr) ' rate = ' ...
		  num2str(rate) ' msglen = ' num2str(msglen)])
	  test_wifi_chain('perlen', snr, msglen, rate, NPKTS)
	end
      end
    end
  end

end
