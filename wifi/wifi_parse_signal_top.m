
%----------------------------------------------------------------------------------------------------------------------------
function [stats data rx_data_bits_dec ndbps nsyms] = wifi_parse_signal_top(data, opt, stats, rx_data_bits_dec)
%----------------------------------------------------------------------------------------------------------------------------
  [rate length modu code parityCheck valid ndbps nsyms] = wifi_parse_signal(rx_data_bits_dec);
  display('------------------------------------------------------------');
  display('parse signal results: ');
  display('data bits:');
  rx_data_bits_dec = rx_data_bits_dec
  display(strcat('rate: ', num2str(rate), ' length: ', num2str(length), ' code: ', num2str(code), ...
  	' parityCheck: ', num2str(parityCheck), ' valid: ', num2str(valid), ...
	' ndbps: ', num2str(ndbps), ' nsyms:', num2str(nsyms)));
  display('------------------------------------------------------------');
  data.sig_rate = rate;
  data.sig_payload_length = length;
  data.sig_modu = modu;
  data.sig_code = code;
  data.sig_parityCheck = parityCheck;
  data.sig_valid = valid;
  data.sig_ndbps = ndbps;
  data.sig_nsyms = nsyms;
end
