
%------------------------------------------------------------------------------------
function [stats data rx_data_bits_dec] = wifi_wrapper_decode(data, opt, stats, rx_data_bits_depunct, tblen)
%------------------------------------------------------------------------------------
  rx_data_bits_dec = wifi_vdec(rx_data_bits_depunct, opt.soft_slice_nbits, tblen);
  if (opt.writeVars_decode)
  writeVars_decode(rx_data_bits_depunct, opt.soft_slice_nbits, tblen, rx_data_bits_dec);
  end
end

