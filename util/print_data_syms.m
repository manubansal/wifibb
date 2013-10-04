
%----------------------------------------------------------------------------------------------------------------------------
function print_data_syms(opt, data, rx_data_syms_eq_const_pnts, rx_data_bits, rx_data_bits_deint, rx_data_bits_dec)
%----------------------------------------------------------------------------------------------------------------------------
  fprintf(1,'\nbegin print_data_syms');
  pause

  nsyms = size(rx_data_syms_eq_const_pnts, 2)
  factor = 60/0.93;

  factor_t = 848/0.0016;
  rx_data_syms_t_with_cp = fix(data.ofdm_syms_t_with_cp(:,2:end) * factor_t);

  rx_pilot_syms = fix(data.rx_pilot_syms(:,2:end) * factor_t);		%after chi
  %uu_pilot_syms = fix(data.uu_pilot_syms_after_chi(:,2:end) * factor_t);		%after chi
  uu_pilot_syms = fix(data.uu_pilot_syms_before_chi(:,2:end) * factor_t);		%after chi

  phase_correction_vector = fix(data.phase_correction_vector(:,2:end) * factor_t);

  rx_data_syms_before_chi = fix(data.rx_data_syms_before_chi(:,2:end) * factor_t);
  rx_data_syms_eq_const_pnts = fix(rx_data_syms_eq_const_pnts * factor);

  nbits = opt.soft_slice_nbits;
  scale = 2^(nbits - 1);		%for 8 bits, this is 128, so that we can contain the soft estimates in [-128, 128]

  rx_data_bits_deint = rx_data_bits_deint - 64;

  size(rx_data_syms_t_with_cp)
  size(rx_data_syms_before_chi)
  size(rx_pilot_syms)
  size(rx_data_syms_eq_const_pnts)
  size(rx_data_bits)
  size(rx_data_bits_deint)

  ncbps = length(rx_data_bits_deint)/nsyms;

  ndbps = data.sig_ndbps;

  for i = 1:nsyms
	  i = i
          symi_t_with_cp = [(1:80)' rx_data_syms_t_with_cp(:, i)]

	  fprintf(1,'\nconstellation points of after ofdm demod, data subcarriers, before eq\n');
	  i = i
          symi_uneq_pnts = [(1:48)' rx_data_syms_before_chi(:, i)]

	  i = i
	  symi_phase_corr_factor = phase_correction_vector(i)
  

	  i = i
          symi_pilot_syms = [(1:4)' rx_pilot_syms(:, i)]

	  i = i
          symi_uu_pilot_syms = [(1:4)' uu_pilot_syms(:, i)]

	  fprintf(1,'\nequalized constellation points of symbols\n');
	  i = i
          symi_eq_pnts = [(1:48)' rx_data_syms_eq_const_pnts(:, i)]

    	  display('data field soft bits');
	  [(1:48)' (rx_data_bits(:,i) - scale)]	%representing in [-scale, scale], instead of [0, 2*scale]

	  fprintf(1,'\ndeinterleaved bits\n');
  
	  symi = rx_data_bits_deint((ncbps * (i-1) + 1):(ncbps * i), 1);
	  i = i
	  symi_deint = reshape(symi, 4, length(symi)/4)'
	  pause

	  symi = rx_data_bits_dec((ndbps * (i-1) + 1):(ndbps * i), 1);
	  i = i;
	  %symi_dec = reshape(symi, 4 * 8, length(symi)/(4 * 8))'
	  symi_dec = symi';
	  symi_dec_bytes = bitsToBytes(symi_dec)

	  pause
  end
end

