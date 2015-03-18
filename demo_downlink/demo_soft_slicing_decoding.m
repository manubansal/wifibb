function data = demo_soft_slicing_decoding(rx_data_syms, smp, rxp, stats, data)


rate = smp.rate;
rate_chart = smp.rate_chart;

[ndbps, rt120, ncbps, nbpsc, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameter_parser(rxp, rate, rate_chart);

[rx_data_bits]  = wifi_wrapper_demap_packet(rx_data_syms, data.sig_nsyms, data.sig_modu, rxp.soft_slice_nbits);

[stats data rx_data_bits_deint]  	= wifi_wrapper_deinterleave(data, rxp, stats, rx_data_bits, nbpsc);
rx_data_bits_deint = reshape(rx_data_bits_deint, prod(size(rx_data_bits_deint)), 1);
[stats data rx_data_bits_depunct]     = wifi_wrapper_depuncture(data, rxp, stats, rx_data_bits_deint, data.sig_code);

%decode the actual data length portion
data_and_tail_length_bits = smp.service_bits + data.sig_payload_length * 8 + smp.tail_bits;	%first 16 for service, last 6 for tail
actual_data_portion_with_tail = rx_data_bits_depunct(1:(data_and_tail_length_bits * 2));	%since it's a half rate code
[rx_data_bits_dec]         = wifi_wrapper_decode(actual_data_portion_with_tail, smp.service_bits + data.sig_payload_length * 8, rxp);

%descramble
rx_data_bits_descr = wifi_descramble(rx_data_bits_dec);

%retain only upto the data portion, including service field but discarding tail and pad
rx_data_bits_descr = rx_data_bits_descr(1:(smp.service_bits + data.sig_payload_length * 8));
rx_data_bytes = reshape(rx_data_bits_descr, 8, data.sig_payload_length + (smp.service_bits/8));

%parse payload
[parsed_data frame_type ber crcValid service_field da seq] = wifi_parse_payload(rx_data_bytes);
data.parsed_data = parsed_data;
data.frame_type = frame_type;
data.ber = ber;
data.crcValid = crcValid;
data.service_field = service_field;
data.da = da;
data.seq = seq;


end

