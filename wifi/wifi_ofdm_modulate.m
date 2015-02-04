%datasyms are frequency domain symbols with just the data subcarriers
function [tdsyms_w_cp, tdsyms] = wifi_ofdm_modulate(datasyms, cplen)
    copt = {};
    copt = wifi_common_parameters(copt);
    cplength = copt.cp_len_s;

    nsubc = copt.nsubc; 			%number of subcarriers
    ndatasubc = copt.ndatasubc;
    npsubc = copt.npsubc;
    ndatapilotsubc = ndatasubc + npsubc;

    nsyms = size(datasyms, 2);

    dsubc_idx = copt.dsubc_idx;	%regular order (dc in middle)
    dsubc_ind = zeros(nsubc,1);
    dsubc_ind(dsubc_idx) = 1;
    [dsubc_ind [1:nsubc]'];
    dsubc_ind_shifted = fftshift(dsubc_ind);
    dsubc_idx_shifted = find(dsubc_ind_shifted);


    datasyms_shifted = [datasyms(ndatasubc/2+1:end,:); datasyms(1:ndatasubc/2,:)];
    fdsyms = zeros(nsubc, nsyms);
    %dsubc_idx_shifted
    %pause
    fdsyms(dsubc_idx_shifted, :) = datasyms_shifted;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %add pilot subcarriers
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pilot_sc = copt.pilot_sc;

    pilot_sc_ext = [pilot_sc pilot_sc pilot_sc pilot_sc pilot_sc]; %127 * 5 = 635 long - enough for all packet lengths

    psubc_idx = copt.psubc_idx;	%regular order (dc in middle)
    psubc_ind = zeros(nsubc,1);
    psubc_ind(psubc_idx) = 1;
    [psubc_ind [1:nsubc]'];
    psubc_ind_shifted = fftshift(psubc_ind);
    psubc_idx_shifted = find(psubc_ind_shifted) ;    %[8; 22; 44; 58]

    % pilot symbols to load on the above indices: [1 -1 1 1] * polarity, (corresponding 
    % to [1 1 1 -1] * polarity in natural order)

    pilotsyms = diag(copt.intrasym_pilot_sc) * ones(npsubc, nsyms);
    polarity = pilot_sc_ext(1:nsyms);
    pilotsyms = pilotsyms * diag(polarity);
    fpsyms = zeros(nsubc, nsyms);
    fpsyms(psubc_idx_shifted, :) = pilotsyms;

    %[fdsyms fpsyms]

    fsyms_data_and_pilot = fdsyms + fpsyms;


    tdsyms = ifft(fsyms_data_and_pilot);

    %verify that the dc components are near-zero
    dc_component = sum(tdsyms);

    %add cyclic prefixes and additional sample for windowing
    prefixes = tdsyms([end-cplength+1:end], :);
    tdsyms_w_cp = [prefixes; tdsyms];
end
