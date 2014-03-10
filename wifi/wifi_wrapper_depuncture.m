
%------------------------------------------------------------------------------------
function [stats data rx_data_bits_depunct] = wifi_wrapper_depuncture(data, opt, stats, rx_data_bits_deint, coderate)
%------------------------------------------------------------------------------------
  rx_data_bits_depunct = wifi_softDepuncture(rx_data_bits_deint, opt.soft_slice_nbits, coderate);
  if (opt.writeVars_depuncture)
  writeVars_depuncture(rx_data_bits_deint, opt.soft_slice_nbits, coderate, rx_data_bits_depunct);
  end
end
