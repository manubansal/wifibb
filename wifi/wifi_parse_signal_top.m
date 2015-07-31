
%------------------------------------------------------------------------------------
function [stats data rx_data_bits_dec ndbps nsyms] = wifi_parse_signal_top(data, sim_params, copt, opt, stats, rx_data_bits_dec, use_length_field_for_seq_no, data_len)
%------------------------------------------------------------------------------------
  if (nargin < 7)
    use_length_field_for_seq_no = false;
    data_len = 0;
  end

  [rate length modu code parityCheck valid ndbps nsyms seqno] = wifi_parse_signal(sim_params, copt, rx_data_bits_dec, use_length_field_for_seq_no, data_len);
  display('------------------------------------------------------------');
  display('parse signal results: ');
  %display('data bits:');
  %rx_data_bits_dec = rx_data_bits_dec
  display(strcat('seqno: ', num2str(seqno), ' rate: ', num2str(rate), ' length: ', num2str(length), ' code: ', num2str(code), ...
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
  data.seqno = seqno;
end
