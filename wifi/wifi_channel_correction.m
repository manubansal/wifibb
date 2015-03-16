
function [stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] = wifi_channel_correction(nsyms, opt, data, stats, ofdm_syms_f, chi)
  [ndbps, rt120, ncbps, nbpsc, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameter_parser(opt, 0);
  %chi = data.chi;
  tx_pilot_syms = data.sig_and_data_tx_pilot_syms(:,1:nsyms);

  %------- channel correction -------------
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % channel correction (equalization)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %equalize
  %size(diag(chi))
  %size(ofdm_syms_f)
  ofdm_syms_f = diag(chi) * ofdm_syms_f;
  %------ done channel correction -------------



  %------ separate data and pilot tones -------
  rx_pilot_syms = ofdm_syms_f(psubc_idx, :);

  %for debug
  data.rx_pilot_syms = rx_pilot_syms;

  %size(rx_pilot_syms)
  %size(tx_pilot_syms)
  %pause

  uu_pilot_syms = rx_pilot_syms .* conj(tx_pilot_syms);				%tx pilot symbols are all +-1, so this gives 
  										%the rx symbol corresponding to tx symbol 1


  %for debug
  data.uu_pilot_syms_after_chi = uu_pilot_syms;

end
