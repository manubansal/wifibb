
function tx_sig_field = wifi_pack_signal(rate, len)
  %display('wifi_parse_signal input:');
  %rx_sig_field

  rate_idx = [6 7 2 3 4 5 0 1];

  rate_chart = [6 9 12 18 24 36 48 54];
  %modu_chart = [1 1 2 2 4 4 6 6];
  %code_chart = [60 90 60 90 60 90 80 90];
  %ndbps_chart = [24 36 48 72 96 144 192 216];

  valid = true;

  tx_sig_field = zeros(1,24);

  rate_field = zeros(1,4);
  rate_field(4) = 1;

  idx = find(rate == rate_chart);
  rate_idx = rate_idx(idx);
  rate_field(1:3) = de2bi(rate_idx, 3, 'left-msb');

  length_field = fliplr(de2bi(len, 12, 'left-msb'));

  tx_sig_field(1:4) = rate_field;
  tx_sig_field(6:17) = length_field;
  
  parity_field = mod(sum(tx_sig_field(1:17)), 2);
  
  tx_sig_field(18) = parity_field;


  %len_service = 16;
  %len_tail = 6;
  %len_data_portion = len * 8 + len_service + len_tail;

  %if (valid)
  %  ndbps = ndbps_chart(idx);
  %  nsyms = ceil(len_data_portion/ndbps);
  %  phy_payload_length = len;
  %else
  %  ndbps = 0;
  %  nsyms = 0;
  %  phy_payload_length = 0;
  %end
  %pause
end
