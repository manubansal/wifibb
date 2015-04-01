
%----------------------------------------------------------------------------------------------------------------------------
function [stats data ofdm_syms_f] = wifi_ofdm_demod(samples, nsyms, data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  %------- data demodulation ---------
  data_samples = samples(1:(opt.sym_len_s*nsyms));

  noise_win_len = opt.noise_win_len;
  noise_fft_size = opt.noise_fft_size;
  stf_len = opt.stf_len;
  ltf_len = opt.ltf_len;
  sig_len = opt.sig_len;
  stf_shift_len = opt.stf_shift_len;
  ltf_shift_len = opt.ltf_shift_len;
  sample_duration_sec = opt.sample_duration_sec;

  sym_len_s  = opt.sym_len_s ;
  cp_len_s  = opt.cp_len_s ;
  fft_size  = opt.fft_size ;
  cp_skip  = opt.cp_skip ;

  n_syms = length(data_samples)/sym_len_s;
  data.worst_samples_3 = data_samples;
  %size(data_samples)
  ofdm_syms_t = reshape(data_samples, sym_len_s, n_syms);
  %size(ofdm_syms_t)
  %pause
  %data_samples(1:160)
  %ofdm_syms_t(:,[1 2])

  %for debug
  data.ofdm_syms_t_with_cp = ofdm_syms_t;
  data.worst_samples_2 = data.ofdm_syms_t_with_cp;

  %remove cp
  ofdm_syms_t = ofdm_syms_t(1+cp_skip:cp_skip+fft_size,:);

  %for debug
  data.ofdm_syms_t_no_cp = ofdm_syms_t;
  data.worst_samples_1 = data.ofdm_syms_t_no_cp;

  %ofdm demod
  ofdm_syms_f = fftshift(fft(ofdm_syms_t),1);	%fftshift along rows (each column is fftshifted)

  tx_pilot_syms = data.sig_and_data_tx_pilot_syms(:,1:nsyms);
  %%%%%tx_data1_syms = data.tx_data_syms(d1subc_idx, :);


  [ndbps, rt120, ncbps, nbpsc, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameter_parser(opt,0);


  rx_pilot_syms_before_chi = ofdm_syms_f(psubc_idx, :);
  rx_data_syms_before_chi = ofdm_syms_f(dsubc_idx, :);

  %for debug
  uu_pilot_syms_before_chi = rx_pilot_syms_before_chi .* conj(tx_pilot_syms);	%tx pilot symbols are all +-1, so this gives 
  data.uu_pilot_syms_before_chi = uu_pilot_syms_before_chi;
  data.rx_data_syms_before_chi = rx_data_syms_before_chi;

end
