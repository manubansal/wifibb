
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

%------------------------------------------------------------------------------------
function [stats data rx_data_bits] = demapPacket_old(rx_data_syms, data, opt, stats)
%------------------------------------------------------------------------------------

  %rx_data_syms = data.rx_data_syms;

  if (prod(size(rx_data_syms)) == 0)
    return;
  end
  %stats.n_packets_processed = stats.n_packets_processed + 1;

  util_plotConstellation(rx_data_syms, opt);

  %hard-demap symbols to bits according to bpsk
  rx_data_syms_i = real(rx_data_syms);
  rx_data_bits_i = sign(rx_data_syms_i);	%contains 1, -1 and 0
  rx_data_bits_i = fix((rx_data_bits_i + 1)/2);	%contains 1 and 0 only

  %data.rx_data_bits_i = rx_data_bits_i;
  %data.rx_data_bits_q = rx_data_bits_q;
  %data.rx_data_bits_q = rx_data_bits_i;

  %[this_ndsubc this_nsyms] = size(rx_data_bits_i);
  %this_ndsubc_2 = (1:this_ndsubc)*2;
  %rx_data_bits(this_ndsubc_2 - 1, :) = data.rx_data_bits_i;
  %rx_data_bits(this_ndsubc_2, :) = data.rx_data_bits_q;
  rx_data_bits = rx_data_bits_i;
  rx_data_bits = rx_data_bits * 255;	%making bits soft
end

