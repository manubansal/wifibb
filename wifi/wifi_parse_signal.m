
function [rate len modu code parityCheck valid ndbps nsyms] = wifi_parse_signal(sim_params, common_params, rx_sig_field)
  %display('wifi_parse_signal input:');
  %rx_sig_field

  rate_idx = [6 7 2 3 4 5 0 1];

  %rate_chart = [48 54 12 18 24 36 6 9];
  modu_chart = common_params.wifi_nbpsc;
  code_chart = common_params.wifi_rt120;
  ncbps_chart = modu_chart*common_params.ndatasubc;
  ndbps_chart = ncbps_chart.*code_chart/120;
    
  rate_chart = ndbps_chart/(common_params.sample_duration_sec*common_params.sym_len_s*10^6);

    
%   ndbps_chart = [24 36 48 72 96 144 192 216];

  valid = true;

  rate_field = rx_sig_field(1:4);
  if (rate_field(4) == 0)
    rate = 0;
    modu = 0;
    code = 0;
    valid = false;
  else
    rate_field_dec = 4 * rate_field(1) + 2 * rate_field(2) + rate_field(3);
    idx = find(rate_idx == rate_field_dec);
    rate = rate_chart(idx);
    modu = modu_chart(idx);
    code = code_chart(idx);
  end

  length_field = rx_sig_field(6:17);
  pow_2 = 2.^(0:11);
  length_field = reshape(length_field, 1, length(length_field));
  len = sum(pow_2 .* length_field);

  if (len > 1600)
    valid = false
  end
  
  parity_field = rx_sig_field(1:18);
  parityCheck = false;
  if (mod(sum(parity_field), 2) == 0)
    parityCheck = true;
  end

  len_service = sim_params.service_bits;
  len_tail = sim_params.tail_bits;
  len_data_portion = len * 8 + len_service + len_tail;

  if (valid)
    ndbps = ndbps_chart(idx);
    nsyms = ceil(len_data_portion/ndbps);
    phy_payload_length = len;
  else
    ndbps = 0;
    nsyms = 0;
    phy_payload_length = 0;
  end
  %pause
end
