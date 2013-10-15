
function [stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] = wifi_pilot_phase_tracking(stats, data, opt, ofdm_syms_f, uu_pilot_syms, nsyms)
  
  if (opt.PILOT_PHASE_TRACKING)
    display('pilot based phase tracking and compensation');
    [ndbps, rt120, ncbps, nbpsc, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameters(0)
    tx_pilot_syms = data.sig_and_data_tx_pilot_syms(:,1:nsyms);
    %size(uu_pilot_syms)
    uu_pilot_syms_avg = sum(uu_pilot_syms)/4;
    uu_pilot_syms_avg_ph = angle(uu_pilot_syms_avg);
    phase_correction = exp(-i*uu_pilot_syms_avg_ph);
    %size(ofdm_syms_f)
    %size(phase_correction)
    %pause

    %for debug
    data.phase_correction_vector = phase_correction;
    
    ofdm_syms_f = ofdm_syms_f * diag(phase_correction);

    %resample pilots after this correction, so the further stages can use this stage's correction
    rx_pilot_syms = ofdm_syms_f(psubc_idx, :);
    uu_pilot_syms = rx_pilot_syms .* tx_pilot_syms;	%tx pilot symbols are all +-1, so this gives 
  							%the rx symbol corresponding to tx symbol 1
  else
    display('pilot based phase tracking and compensation is disabled');
  end

  %%%%%%%%%%%%%%%%%%%%%%%
  %  display('plcp signal field in frequency domain after equalization and pilot phase correction');
  %  if (opt.printVars_ofdmEqualizedPlcp)
  %          display('plcp data subcarriers:');
  %          size(ofdm_syms_f)
  %          size(dsubc_idx)
  %        [ [1:48]' fix(opt.ti_factor_after_cfo * ofdm_syms_f(dsubc_idx, 1))]
  %          display('plcp pilot subcarriers:');
  %          size(uu_pilot_syms)
  %        [ [1:4]' fix(opt.ti_factor_after_cfo * uu_pilot_syms(:,1))]
  %        if (opt.PAUSE_AFTER_EVERY_PACKET)
  %          pause
  %        end
  %  end
  %%%%%%%%%%%%%%%%%%%%%%%
end
