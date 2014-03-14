
%----------------------------------------------------------------------------------------------------------------------------
function [parsed_data frame_type ber crcValid service_field da seq] = wifi_parse_payload(databytes)	
%databytes format: each column is a byte, top of a byte being the earliest bit

  %display('service field:');
  service_field = databytes(:,1:2);
  service_field = service_field(:).';

  databytes = databytes(:,3:end);


  %function [parsed_data frame_type ber crcValid] = wifi_parse_phy_payload(databytes)
  %[data.parsed_data data.frame_type data.ber data.crcValid] = wifi_parse_phy_payload(databytes);
  %%%%[parsed_data frame_type ber crcValid] = wifi_parse_phy_payload(databytes);


  %databytes = databytes

  m = 2.^(0:7)';	%oldest is lsb
  b = (diag(m) * databytes);
  databytes_dec = sum(b);
  databytes_hex = dec2hex(databytes_dec, 2);

  databytes_hex_with_crc32 = databytes_hex;
  %pause

  da = databytes_hex(5:10, :);
  da = da.';
  da = da(:);
  da = da';

  seq = databytes_hex(11, :);

  [crc_val crcValid] = wifi_crc32(databytes_hex_with_crc32);
  frame_type = 2; ber = -1;
  parsed_data = databytes_hex;
  %pause

end
%----------------------------------------------------------------------------------------------------------------------------
