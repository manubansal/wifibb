
function rx_data_field = wifi_rx_chain_simple(rx_samples_f, rate, n_ofdm_syms, base_msg_len_bits, softbit_scale_nbits, tblen)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% configure parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  [ndbps, rt120, ncbps, nbpsc] = wifi_parameters(rate);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% demap symbols
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %function softbits = wifi_softSlice(points, nbpsc, softbit_scale_nbits, range)
  rx_syms = reshape(rx_samples_f, length(rx_samples_f)/n_ofdm_syms, n_ofdm_syms);
  rx_syms_softbits = [];
  for i = 1:n_ofdm_syms
    rx_syms_softbits = [rx_syms_softbits wifi_softSlice(rx_syms(:,i), nbpsc, softbit_scale_nbits)];
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% deinterleave softbits
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  t = wifi_deinterleaveTables();
  rx_syms_deint = wifi_deinterleave(t, rx_syms_softbits, nbpsc);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% depuncture softbits
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  rx_softbits_deint = reshape(rx_syms_deint, prod(size(rx_syms_deint)), 1);
  rx_softbits_depunc = wifi_softDepuncture(rx_softbits_deint, softbit_scale_nbits, rt120);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% decode softbits
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %discard pad bits
  n_bits_to_keep = (base_msg_len_bits + 16 + 6) * 2;
  rx_softbits_depunc = rx_softbits_depunc(1:n_bits_to_keep);
  %function [ dmsg ] = wifi_vdec(incode, softbit_scale_nbits, tblen, initmetric, initstates, initinputs)
  rx_decoded_bits = wifi_vdec(rx_softbits_depunc, softbit_scale_nbits, tblen);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% descramble bits
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  [rx_descrambled_bits descr_seq] = wifi_descramble(rx_decoded_bits);
  
  rx_service_field = rx_descrambled_bits(1:16);
  rx_data_field = rx_descrambled_bits(16+1:16+base_msg_len_bits);
  rx_tail_field = rx_descrambled_bits(16+base_msg_len_bits+1:end);

  %[rx_data_field base_msg]
  %base_msg
  %whos
  %pause
  base_msg_len_bits
  size(descr_seq)
  whos

  %scr_seq_no_pad = scr_seq(1:(16 + base_msg_len_bits + 6));
  %[(1:length(descr_seq))' scr_seq_no_pad descr_seq]
  %pause
  %rx_service_field = rx_service_field
  %rx_tail_field = rx_tail_field
end
