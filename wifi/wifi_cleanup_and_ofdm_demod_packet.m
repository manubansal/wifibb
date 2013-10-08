
%----------------------------------------------------------------------------------------------------------------------------
function [stats data rx_data_syms] = wifi_cleanup_and_ofdm_demod_packet(samples, nsyms, data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  %------- data demodulation ---------
  data_samples = samples(1:(opt.sym_len_s*nsyms));
  chi = data.chi;

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
  %size(data_samples)
  ofdm_syms_t = reshape(data_samples, sym_len_s, n_syms);
  %size(ofdm_syms_t)
  %pause
  %data_samples(1:160)
  %ofdm_syms_t(:,[1 2])

  %for debug
  data.ofdm_syms_t_with_cp = ofdm_syms_t;

  %remove cp
  ofdm_syms_t = ofdm_syms_t(1+cp_skip:cp_skip+fft_size,:);

  %for debug
  data.ofdm_syms_t_no_cp = ofdm_syms_t;

  %ofdm demod
  ofdm_syms_f = fftshift(fft(ofdm_syms_t),1);	%fftshift along rows (each column is fftshifted)

  tx_pilot_syms = data.sig_and_data_tx_pilot_syms(:,1:nsyms);
  %%%%%tx_data1_syms = data.tx_data_syms(d1subc_idx, :);


  %%%%%%%%%%%%%%%%%%%%%%%
  nsubc = 64;
  psubc_idx = (nsubc/2)+[(1+[-21 -7 7 21])];					%regular order (dc in middle)
  dsubc_idx = (nsubc/2)+[(1+[-26:-22 -20:-8 -6:-1]) (1+[1:6 8:20 22:26])];	%regular order (dc in middle)
    display('plcp signal field in frequency domain before equalization');
    if (opt.printVars_ofdmDemodPlcp)
	    display('plcp data subcarriers:');
	  [ [1:48]' fix(opt.ti_factor_after_cfo * ofdm_syms_f(dsubc_idx, 1))]
	    display('plcp pilot subcarriers:');
	  [ [1:4]' fix(opt.ti_factor_after_cfo * (ofdm_syms_f(psubc_idx, 1) .* conj(tx_pilot_syms(:,1))))]
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
	    pause
	  end
    end
  %%%%%%%%%%%%%%%%%%%%%%%


  %------ data and pilot subcarrier indices ------
  nsubc = 64; 									%number of subcarriers
  psubc_idx = (nsubc/2)+[(1+[-21 -7 7 21])];					%regular order (dc in middle)
  %pause

  d1subc_idx = (nsubc/2)+[(1+[-32 -1 1 31])];					%regular order (dc in middle)
  %-------------------------------------------------


  rx_pilot_syms_before_chi = ofdm_syms_f(psubc_idx, :);
  rx_data_syms_before_chi = ofdm_syms_f(dsubc_idx, :);

  %for debug
  uu_pilot_syms_before_chi = rx_pilot_syms_before_chi .* conj(tx_pilot_syms);	%tx pilot symbols are all +-1, so this gives 
  data.uu_pilot_syms_before_chi = uu_pilot_syms_before_chi;
  data.rx_data_syms_before_chi = rx_data_syms_before_chi;

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

  dsubc_idx = (nsubc/2)+[(1+[-26:-22 -20:-8 -6:-1]) (1+[1:6 8:20 22:26])];	%regular order (dc in middle)


  
  if (opt.PILOT_PHASE_TRACKING)
    display('pilot based phase tracking and compensation');
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

   
  if (opt.PILOT_SAMPLING_DELAY_CORRECTION)
    display('pilot based sampling delay (due to sampling freq offset) correction');

    % Algorithm:
    % y=[y-21; y-7; y7; y21;]
    % x=[-21 -7 7 21]
    % y = px => y = xp, p is a scalar to be determined: that's the linear model of phase offset
    % then, p_opt (MSE) = pinv(x).y, where pinv(x) = (x^T x)^-1 x^T, so that with dc considered 
    % to be subcarrier index k = 0, p = (1/980)*(-21.y(-21) + -7.y(-7) + 7.y(7) + 21.y(21)], where
    % y's reflect phases (mod 2*pi, so that they all like in [0,2*pi) and averaging is valid)
    % of the respective subcarriers. Phase correction coefficients can then be generated according 
    % to exp(-jkp).

    %%%%% begin algorithm 1 %%%%%%%%
    %p_vec = (1/980)*([-21 -7 7 21] * mod(angle(uu_pilot_syms),2*pi));
    p_vec = (1/980)*([-21 -7 7 21] * angle(uu_pilot_syms));
    %%%%% finish algorithm 1 %%%%%%%%

    %%%%%%%%%% begin algorithm 2 %%%%%%%%
    %%%%%circular_angles = angle(uu_pilot_syms);

    %%%%%%figure
    %%%%%%hold on
    %%%%%%%plot(angle(uu_pilot_syms(1,:)),'r.-')
    %%%%%%plot(angle(uu_pilot_syms(2,:)),'g.-')
    %%%%%%plot(angle(uu_pilot_syms(3,:)),'b.-')
    %%%%%%%plot(angle(uu_pilot_syms(4,:)),'k.-')
    %%%%%%title('pilot tone 1-4, rgbk angle(.), before sampling offset correction, after common phase removal')
    %%%%%%pause

    %%%%%a1=circular_angles(1,:); a2=circular_angles(2,:); a3=circular_angles(3,:); a4=circular_angles(4,:);
    %%%%%a1 = mod(a1,2*pi*sign(a2));			%NOTE: This includes the ASSUMPTION that the linear angle
    %%%%%						%at the outer subpilot will not exceed 2*pi in magnitude,
    %%%%%    					%which is saying that the maximum sampling "phase" offset
    %%%%%    					%at that subcarrier will not be more than 2*pi, or maximum
    %%%%%    					%sampling delay will not be more than T such 2*pi*(312.5kHz*21)*T = 2*pi,
    %%%%%    					%or, T_max = 1(312.5*21) ms = 152ns. This is true since sample
    %%%%%    					%duration is 50ns. (What happens if sampling delay has indeed 
    %%%%%    					%accummulated to more than 50ns and we have jumped a sample?)
    %%%%%    					%(Also, the above is true only if other phase contributions, like
    %%%%%    					%that from CFO, multipath channel and system response, have 
    %%%%%    					%already been corrected, not when they have been pushed to 
    %%%%%    					%this stage).

    %%%%%a4 = mod(a4,2*pi*sign(a3));
    %%%%%prod_sign = sign(a2).*sign(a3)		%must be -1
    %%%%%linear_angles = [a1; a2; a3; a4];
    %%%%%circular_angles(:,[1:20])
    %%%%%linear_angles(:,[1:10])
    %%%%%pause

    %%%%%p_vec = (1/980)*([-21 -7 7 21] * (linear_angles));
    %%%%%%%%%% finish algorithm 2 %%%%%%%%
    %%%%%%%%% this one seems buggy %%%%%

    p_corr_terms = exp(-i * diag([-32:31]) * ones(64,size(ofdm_syms_f,2)) * diag(p_vec));
    ofdm_syms_f = ofdm_syms_f .* p_corr_terms;

    rx_pilot_syms = ofdm_syms_f(psubc_idx, :);
    uu_pilot_syms = rx_pilot_syms .* tx_pilot_syms;	%tx pilot symbols are all +-1, so this gives 
  							%the rx symbol corresponding to tx symbol 1


  else
    display('pilot based sampling delay (due to sampling freq offset) correction is disabled');
  end

  rx_data_syms = ofdm_syms_f(dsubc_idx, :);
  %data.rx_data_syms = rx_data_syms; 

  %%%%rx_data1_syms = ofdm_syms_f(d1subc_idx, :);
  %%%%uu_data1_syms = rx_data1_syms .* conj(tx_pilot_syms);

  %display('rx_pilot_syms, tx_pilot_syms, uu_pilot_syms:');
  %[rx_pilot_syms(:,[1:5]) tx_pilot_syms(:,[1:5]) uu_pilot_syms(:,[1:5])]

  if (opt.GENERATE_PER_PACKET_PLOTS)
    figure
    subplot(3,1,1)
    hold on
    plot(abs(uu_pilot_syms(1,:)),'r.-')
    plot(abs(uu_pilot_syms(2,:)),'g.-')
    plot(abs(uu_pilot_syms(3,:)),'b.-')
    plot(abs(uu_pilot_syms(4,:)),'k.-')
    title('pilot tone 1-4, rgbk, |.|')

    subplot(3,1,2)
    hold on
    plot(10*log10(abs(uu_pilot_syms(1,:))),'r.-')
    plot(10*log10(abs(uu_pilot_syms(2,:))),'g.-')
    plot(10*log10(abs(uu_pilot_syms(3,:))),'b.-')
    plot(10*log10(abs(uu_pilot_syms(4,:))),'k.-')
    title('pilot tone 1-4, rgbk, |.| dB')

    subplot(3,1,3)
    hold on
    plot(angle(uu_pilot_syms(1,:)),'r.-')
    plot(angle(uu_pilot_syms(2,:)),'g.-')
    plot(angle(uu_pilot_syms(3,:)),'b.-')
    plot(angle(uu_pilot_syms(4,:)),'k.-')
    title('pilot tone 1-4, rgbk angle(.)')

    %subplot(4,1,3)
    %plot(abs(uu_pilot_syms(2,:)))
    %title('pilot tone 2, |.|')

    %subplot(4,1,4)
    %plot(angle(uu_pilot_syms(2,:)))
    %title('pilot tone 2, angle(.)')
  end

  %pause

  %display('first three ofdm symbols in frequency domain (each col is a symbol):');
  %ofdm_syms_f(:,1:3)

end
