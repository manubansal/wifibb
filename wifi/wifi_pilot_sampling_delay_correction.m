
function [stats data rx_data_syms rx_pilot_syms uu_pilot_syms ofdm_syms_f] = ...
wifi_pilot_sampling_delay_correction(stats, data, opt, ofdm_syms_f, uu_pilot_syms, nsyms)

  if (opt.PILOT_SAMPLING_DELAY_CORRECTION)
    display('pilot based sampling delay (due to sampling freq offset) correction');

    [ndbps, rt120, ncbps, nbpsc, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameter_parser(opt,0);

    tx_pilot_syms = data.sig_and_data_tx_pilot_syms(:,1:nsyms);
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
    psubc_centered_idx = opt.psubc_idx -1-(opt.nsubc/2);
    p_vec = (1/(psubc_centered_idx*psubc_centered_idx'))*(psubc_centered_idx * angle(uu_pilot_syms));
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

    p_corr_terms = exp(-i * diag([-(opt.nsubc/2):(opt.nsubc/2)-1]) * ones(opt.nsubc,size(ofdm_syms_f,2)) * diag(p_vec));
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


end
