
%----------------------------------------------------------------------------------------------------------------------------
function print_deinterleave(rx_data_bits_deint)
%----------------------------------------------------------------------------------------------------------------------------
  fprintf(1,'\nbegin print_deinterleave');

  fprintf(1,'\ndeinterleaved bits\n');
  size(rx_data_bits_deint)
  %rx_data_bits_deint = reshape(rx_data_bits_deint, prod(size(rx_data_bits_deint)), 1);
  %size(rx_data_bits_deint)

  %[rx_data_bits_deint(1:10) rx_data_bits_deint(1:10) - 64]
  rx_data_bits_deint = rx_data_bits_deint - 64;
  
  nsyms = size(rx_data_bits_deint, 2);
  %rx_data_bits_deint = rx_data_bits_deint';	%each row is a symbol

  for i = 1:nsyms
	  symi = rx_data_bits_deint(:, i);
	  i = i
	  symi_deint = reshape(symi, 4, length(symi)/4)'
	  pause
  end

  %pause

  %util_writeVarToCFile(rx_data_bits_deint, ['rx_data_bits_deint_len_',num2str(length(rx_data_bits_deint))], 0, 0, 'Int8', 1, 1);		%Qval = 0 corresponds to integer
  fprintf(1,'end print_deinterleave\n');
  %pause
end
