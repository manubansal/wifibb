
function [symbols_out, databits_i, databits_q] = wifi_mapper_mapbpsk(input_bits)
  %Generate BPSK symbol table:
  BPSK = [-1, 1];


  symbols_out = zeros(48,1);
  %loop through 2 bits at a time and generate output symbols
  for i=1:1:length(input_bits)
      bits_string = [num2str(input_bits(i))];
      switch(bits_string)
	  case '0'
	      symbol_out = BPSK(1);
	  case '1'
	      symbol_out = BPSK(2);
      end
      
      symbols_out(i) = symbol_out;
  end

  %hex_input_bits = convert_cell_array_to_cstyle(convert_bits_to_unpacked(input_bits))

  %symbols_out = fi(symbols_out,1,16,9);

  %symbols_cstyle = convert_complex_to_cstyle(symbols_out.int16)
  databits_i = input_bits;
  databits_q = zeros(size(databits_i));
end
