
function [QAM16_symbols_out, databits_i, databits_q] = wifi_mapper_map64qam(input_bits)

  %Generate 16qam symbol table:
  %From 0000-1111
  QAM16 = [-3-3j
	      -3-1j
	      -3+3j
	      -3+1j
	      -1-3j
	      -1-1j
	      -1+3j
	      -1+1j
	      +3-3j
	      +3-1j
	      +3+3j
	      +3+1j
	      +1-3j
	      +1-1j
	      +1+3j
	      +1+1j]./sqrt(10);



  QAM16_symbols_out = zeros(48,1);
  %loop through 2 bits at a time and generate output symbols
  for i=1:4:length(input_bits)
      bits_string = [num2str(input_bits(i)) num2str(input_bits(i+1)) num2str(input_bits(i+2)) num2str(input_bits(i+3))];
      symbol_out = QAM16(bin2dec(bits_string) + 1); 
      QAM16_symbols_out((i-1)/4 + 1) = symbol_out;
  end

  %%hex_input_bits = convert_cell_array_to_cstyle(convert_bits_to_unpacked(input_bits))

  %%QAM16_symbols_out = fi(QAM16_symbols_out,1,16,9);

  %%QAM16_symbols_cstyle = convert_complex_to_cstyle(QAM16_symbols_out.int16)
  ib = reshape(input_bits, 4, []);
  databits_i = reshape(input_bits(1:2, :), 1, []);
  databits_q = reshape(input_bits(3:4, :), 1, []);
end
