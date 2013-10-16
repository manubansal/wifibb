
%----------------------------------------------------------------------------------------------------------------------------
function writeVars_decode(rx_data_bits_depunct, nbits_precision, tblen, rx_data_bits_dec)
%----------------------------------------------------------------------------------------------------------------------------
  fprintf(1,'\nbegin writeVars_decode');
  util_writeVarToCFile(rx_data_bits_dec, ['rx_data_bits_dec_len_',num2str(length(rx_data_bits_dec))], 0, 0, 'Uint8', 1, 1);			%Qval = 0 corresponds to integer
  fprintf(1,'end writeVars_decode\n');
end
