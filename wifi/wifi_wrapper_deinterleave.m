
%------------------------------------------------------------------------------------
function [stats data rx_data_bits_deint] = wifi_wrapper_deinterleave(data, opt, stats, rx_data_bits, nbpsc)
%------------------------------------------------------------------------------------
  t = data.deinterleave_tables;
  %size(rx_data_bits)
  rx_data_bits_deint = wifi_deinterleave(t, rx_data_bits, nbpsc);
  %size(rx_data_bits_deint)

  if (opt.writeVars_deinterleave)
    writeVars_deinterleave(rx_data_bits, rx_data_bits_deint);
  end

  %%%%%%%%%%%%%%%%%%%%%%%
  if (opt.printVars_softBits_deint)
	display('plcp signal field soft bits after deinterleaving');
	nbits = opt.soft_slice_nbits;
	scale = 2^(nbits - 1);		
	      %for 8 bits, this is 128, so that we can contain the soft estimates in [-128, 128]

	size(rx_data_bits_deint)
	size(scale)
	%[[1:length(rx_data_bits)]' (rx_data_bits - scale)]	
	      %representing in [-scale, scale], instead of [0, 2*scale]

	[[1:size(rx_data_bits_deint,1)]' (rx_data_bits_deint(:,1) - scale)]	
	      %representing in [-scale, scale], instead of [0, 2*scale]
  end
  %%%%%%%%%%%%%%%%%%%%%%%

end
