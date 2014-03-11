[samples, n_samples]=load_samples('/home/manub/workspace/wifibb-traces/traces54/spectesting-siggen-rhs/signal_trace_spectesting_neg53_skip0_ns4400.bin', 'cplx');				%contains samples for one packet that was failing

%DO THIS: set tblen to 54
rx_pkts=rx_sample_stream(samples)
rx_pkts_pass = rx_pkts;

%DO THIS: set tblen to 36
rx_pkts=rx_sample_stream(samples)
rx_pkts_fail = rx_pkts;

bytes_pass=rx_pkts_pass{1}{5}
bytes_fail=rx_pkts_fail{1}{5}
d=bytes_pass - bytes_fail
find(d)					%bit indices that were in mismatch
