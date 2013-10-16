
%----------------------------------------------------------------------------------------------------------------------------
function util_print_descramble(rx_data_bits_descr, nbits_per_symbol)
%----------------------------------------------------------------------------------------------------------------------------
  display('descrambled bits, each ROW is a symbol (not each column)');
  size(rx_data_bits_descr)
  nsyms = ceil(length(rx_data_bits_descr)/nbits_per_symbol)
  nbits_ceil = nsyms * (nbits_per_symbol)
  padlength = nbits_ceil - length(rx_data_bits_descr)
  rx_data_bits_descr =  [rx_data_bits_descr zeros(padlength, 1)];
  descr_bits_reshape = reshape(rx_data_bits_descr, nbits_per_symbol, nsyms)';
  descr_bits_out = [(1:nsyms)' descr_bits_reshape]
end
