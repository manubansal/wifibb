
%------------------------------------------------------------------------------------
function [rx_data_bits_dec] = wifi_wrapper_decode(soft_slice_nbits, rx_data_bits_depunct, tblen)
%------------------------------------------------------------------------------------
  rx_data_bits_dec = wifi_vdec(rx_data_bits_depunct, soft_slice_nbits, tblen);
end

