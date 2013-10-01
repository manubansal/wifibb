
function [QPSK_symbols_out, databits_i, databits_q] = wifi_mapper_mapqpsk(input_bits)

  %Generate QPSK symbol table:
  QPSK = [-1-1j,-1+1j, 1-1j, 1+1j]./sqrt(2);


  QPSK_symbols_out = zeros(48,1);
  %loop through 2 bits at a time and generate output symbols
  for i=1:2:length(input_bits)
      bits_string = [num2str(input_bits(i)) num2str(input_bits(i+1))];
      switch(bits_string)
	  case '00'
	      symbol_out = QPSK(1);
	  case '01'
	      symbol_out = QPSK(2);
	  case '10'
	      symbol_out = QPSK(3);
	  case '11'
	      symbol_out = QPSK(4);
      end
      
      QPSK_symbols_out((i+1)/2) = symbol_out;
  end

  %hex_input_bits = convert_cell_array_to_cstyle(convert_bits_to_unpacked(input_bits))
  %
  %QPSK_symbols_out = fi(QPSK_symbols_out,1,16,9);
  %
  %QPSK_symbols_cstyle = convert_complex_to_cstyle(QPSK_symbols_out.int16)

  databits_i = input_bits(1:2:end)
  databits_q = input_bits(2:2:end)
end
