function msg_int_syms = vidwifi_interleave(I_pseudo_code_syms_array, P_pseudo_code_syms_array)
% Interleaver for I_pseudo and P_pseudo. Input has to be reshaped one
% such that size is np_cbps x n_ofdm_syms where np_cbps is a multiple of 48
    
    nsc_ps = 48;
    nI_cbps = size(I_pseudo_code_syms_array, 1);
    nP_cbps = size(P_pseudo_code_syms_array, 1);
    
    n_ofdm_syms = size(I_pseudo_code_syms_array, 2);
    ncbps = nI_cbps + nP_cbps;
    nbpsc = ncbps / nsc_ps;
    
    I_int_array = zeros(size(I_pseudo_code_syms_array));
    P_int_array = zeros(size(P_pseudo_code_syms_array));
    msg_int_syms = zeros(ncbps, n_ofdm_syms);
    
    for r = 1:n_ofdm_syms
        I_int_array(:, r) = vidwifi_shuffle(I_pseudo_code_syms_array(:, r));
        P_int_array(:, r) = vidwifi_shuffle(P_pseudo_code_syms_array(:, r));
    end
 
    % Mix both separately interleaved arrays
    for r = 1:n_ofdm_syms
        col = [I_int_array(:,r); P_int_array(:,r)];
        temp = reshape(col, nsc_ps, []);
        temp = temp';
        msg_int_syms(:, r) = reshape(temp, ncbps, 1);
    end
end
