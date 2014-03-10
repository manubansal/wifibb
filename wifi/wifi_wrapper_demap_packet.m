
%------------------------------------------------------------------------------------
function [rx_data_bits] = wifi_wrapper_demap_packet(rx_data_syms, nsyms, nbpsc, soft_slice_nbits)
%------------------------------------------------------------------------------------
  if (prod(size(rx_data_syms)) == 0)
    return;
  end
  %stats.n_packets_processed = stats.n_packets_processed + 1;

  %rx_data_syms = reshape(rx_data_syms, prod(size(rx_data_syms)), 1);
  rx_data_bits = wifi_softSlice(rx_data_syms, nbpsc, soft_slice_nbits);
end
