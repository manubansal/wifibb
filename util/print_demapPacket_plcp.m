
%----------------------------------------------------------------------------------------------------------------------------
function print_demapPacket_plcp(rx_data_bits, opt)
%----------------------------------------------------------------------------------------------------------------------------
  %%%%%%%%%%%%%%%%%%%%%%%
    display('plcp signal field soft bits');
    nbits = opt.soft_slice_nbits;
    scale = 2^(nbits - 1);		%for 8 bits, this is 128, so that we can contain the soft estimates in [-128, 128]
    if (opt.printVars_softBits_plcp)
	    size(rx_data_bits)
	    size(scale)
	  %[[1:length(rx_data_bits)]' (rx_data_bits - scale)]	%representing in [-scale, scale], instead of [0, 2*scale]
	  [[1:size(rx_data_bits,1)]' (rx_data_bits(:,1) - scale)]	%representing in [-scale, scale], instead of [0, 2*scale]
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
	    pause
	  end
    end
  %%%%%%%%%%%%%%%%%%%%%%%
end
