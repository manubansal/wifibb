function bits_out = wifi_puncturer_threefourths(coded_bits)
  
  n = length(coded_bits);
  if (mod(n,2) ~= 0)
    error('input length is not odd, needed even','bad input length');
  end
  bits_in_a = coded_bits(1:2:n);
  bits_in_b = coded_bits(2:2:n);
  %DATA_TYPE = 64

  NUM_BITS = n/2;

  %do the puncturing
  bits_out = ''
  bits_in_a_str = ''
  bits_in_b_str = ''
  for x=(1:NUM_BITS)
      bits_in_a_str = [ bits_in_a_str num2str(bits_in_a(x))];
      bits_in_b_str = [ bits_in_b_str num2str(bits_in_b(x))];
      %if x is odd, use both a and b
      switch( mod(x-1,3) )
	 case 0
	     %if 1,4,
	     bits_out = [bits_out num2str(bits_in_a(x)) num2str(bits_in_b(x))];
	 
	 case 1
	      bits_out = [bits_out num2str(bits_in_a(x)) ];
	 case 2
	      bits_out = [bits_out num2str(bits_in_b(x)) ];
      end
	 
  end

  bits_out = reshape(bits_out, length(bits_out), 1);

  %a_packed64 = convert_bits_to_hex(bits_in_a_str,DATA_TYPE);
  %b_packed64 = convert_bits_to_hex(bits_in_b_str,DATA_TYPE);
  %
  %output_unpacked = cell(length(bits_out),1);
  %for x=1:length(bits_out)
  %    switch( bits_out(x) )
  %        case '0' 
  %            output_unpacked(x) = cellstr(['0x00']);
  %        case '1' 
  %            output_unpacked(x) = cellstr(['0xFF']);
  %    end
  %end
  %
  %%print output unpacked
  %output_unpacked_print = [ '{ ' ];
  %
  %%for all but last element
  %for x=1:(length(output_unpacked)-1)
  %     output_unpacked_print = [ output_unpacked_print char(output_unpacked(x)) ',' ];
  %     if mod(x,4)==0
  %        output_unpacked_print = [ output_unpacked_print char(10) ];
  %     end
  %         
  %end
  %
  %output_unpacked_print = [ output_unpacked_print char(output_unpacked(length(output_unpacked))) ' }; ' ]

end
