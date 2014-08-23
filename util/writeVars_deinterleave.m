
%----------------------------------------------------------------------------------------------------------------------------
function writeVars_deinterleave(rx_data_bits, rx_data_bits_deint)
%----------------------------------------------------------------------------------------------------------------------------
  fprintf(1,'\nbegin writeVars_deinterleave');

  fprintf(1,'\ndeinterleaved bits\n');
  size(rx_data_bits_deint)
  rx_data_bits_deint = reshape(rx_data_bits_deint, prod(size(rx_data_bits_deint)), 1);
  size(rx_data_bits_deint)

  [rx_data_bits_deint(1:10) rx_data_bits_deint(1:10) - 64]
  rx_data_bits_deint = rx_data_bits_deint - 64;

  util_writeVarToCFile(rx_data_bits_deint, ['rx_data_bits_deint_len_',num2str(length(rx_data_bits_deint))], 0, 0, 'Int8', 1, 1);		%Qval = 0 corresponds to integer
  fprintf(1,'end writeVars_deinterleave\n');
end
