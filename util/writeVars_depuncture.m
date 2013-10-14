
%----------------------------------------------------------------------------------------------------------------------------
function writeVars_depuncture(rx_data_bits_deint, soft_slice_nbits, coderate, rx_data_bits_depunct)
%----------------------------------------------------------------------------------------------------------------------------
  fprintf(1,'\nbegin writeVars_depuncture');

  fprintf(1,'\ndepunctured bits\n');

  size(rx_data_bits_depunct)
  rx_data_bits_depunct = reshape(rx_data_bits_depunct, prod(size(rx_data_bits_depunct)), 1);
  size(rx_data_bits_depunct)

  [rx_data_bits_depunct(1:10) rx_data_bits_depunct(1:10) - 64]
  rx_data_bits_depunct = rx_data_bits_depunct - 64;
  pause

  util_writeVarToCFile(rx_data_bits_depunct, ['rx_data_bits_depunct_len_',num2str(length(rx_data_bits_depunct))], 0, 0, 'Int8', 1, 1);		%Qval = 0 corresponds to integer
  fprintf(1,'end writeVars_depuncture\n');
  pause
end
