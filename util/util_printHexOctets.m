
function util_printHexOctets(hex_octets)
  print_data = hex_octets;
  pad_length = 16 - mod(size(print_data,1), 16);
  pad = repmat(['XX'], pad_length, 1);
  print_data = [print_data; pad];
  spaces = repmat([' '], size(print_data, 1), 1);
  print_data = [print_data spaces];
  print_data = reshape(print_data',48,prod(size(print_data))/48)';
  hex_data_bytes = print_data
end
