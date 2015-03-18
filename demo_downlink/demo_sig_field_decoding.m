function [stats, data] = demo_sig_field_decoding(rx_symbols, smp, rxp, cmp, stats, data)

data.deinterleave_tables = wifi_deinterleaveTables(rxp, smp);

rate = smp.rate_sig;
rate_chart = smp.rate_chart;
nsyms = size(rx_symbols, 2);

[ndbps, rt120, ncbps, nbpsc, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameter_parser(rxp, rate, rate_chart);

[rx_data_bits] = wifi_wrapper_demap_packet(rx_symbols, nsyms, nbpsc, rxp.soft_slice_nbits);

[stats data rx_data_bits_deint]   = wifi_wrapper_deinterleave(data, rxp, stats, rx_data_bits, nbpsc);

[rx_data_bits_dec]  = wifi_wrapper_decode(rx_data_bits_deint, ndbps - 6 , rxp);

[stats data] = wifi_parse_signal_top(data, smp, cmp, rxp, stats, rx_data_bits_dec);

end

