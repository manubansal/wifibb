
rate = 54
len = 169
tx_sig_field = wifi_pack_signal(rate, len)
rx_sig_field = tx_sig_field;
[rate len modu code parityCheck valid ndbps nsyms] = wifi_parse_signal(rx_sig_field)
