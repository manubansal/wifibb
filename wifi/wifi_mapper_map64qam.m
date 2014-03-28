
function [QAM64_symbols_out, databits_i, databits_q] = wifi_mapper_map64qam(input_bits)

  %Generate 64qam symbol table:
	   
  %QAM64 a pain by hand - so we generate and verify with the spec
  iq_pattern = [-7,-5,-1,-3,+7,+5,+1,+3];


  QAM64=zeros(8,8);
  for i=1:8
      for k=1:8
	  QAM64(i,k) = iq_pattern(i) + 1i*iq_pattern(k);
      end
  end
  QAM64 = reshape(transpose(QAM64),64,1)./sqrt(42);


  QAM64_symbols_out = zeros(48,1);
  %loop through 2 bits at a time and generate output symbols
  %%for i=1:6:length(input_bits)
  %%    bits_string = [num2str(input_bits(i)) num2str(input_bits(i+1)) num2str(input_bits(i+2)) ...
  %%        num2str(input_bits(i+3)) num2str(input_bits(i+4)) num2str(input_bits(i+5))];
  %%    symbol_out = QAM64(bin2dec(bits_string) + 1); 
  %%    QAM64_symbols_out((i-1)/6 + 1) = symbol_out;
  %%end

  a=input_bits;
  b=reshape(a,6,[]);
  c=b';
  d=bi2de(c, 'left-msb');
  e = QAM64(d + 1);
  QAM64_symbols_out = e;

  %%hex_input_bits = convert_cell_array_to_cstyle(convert_bits_to_unpacked(input_bits))

  %%%QAM64_symbols_out = fi(QAM64_symbols_out,1,16,9);
  %%QAM64_symbols_out_fi = fi(QAM64_symbols_out,1,16,9);

  %%%QAM64_symbols_cstyle = convert_complex_to_cstyle(QAM64_symbols_out.int16)
  %%QAM64_symbols_cstyle = convert_complex_to_cstyle(QAM64_symbols_out_fi.int16)
  ib = reshape(input_bits, 6, []);
  databits_i = reshape(input_bits(1:3, :), 1, []);
  databits_q = reshape(input_bits(4:6, :), 1, []);
end
