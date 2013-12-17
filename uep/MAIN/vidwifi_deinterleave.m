function [I_pseudo_deint_syms_array, P_pseudo_deint_syms_array] = vidwifi_deinterleave(uep_msg_int_syms, nbpsc, nI_cbps)
% Reverses vidwifi_interleave - (uep_msg_int_syms, nI_bpsc)

    n_ofdm_syms = size(uep_msg_int_syms, 2);
    
    inter_array = zeros(size(uep_msg_int_syms));
    for r = 1:n_ofdm_syms
        temp = reshape(uep_msg_int_syms(:, r), nbpsc, [] );
        temp = temp';
        inter_array(:, r) = temp(:);
    end
    
    I_deint_array = inter_array(1:nI_cbps, :);
    P_deint_array = inter_array(nI_cbps + 1:end, :);
    
    I_pseudo_deint_syms_array = zeros(size(I_deint_array));
    P_pseudo_deint_syms_array = zeros(size(P_deint_array));
    
    for r = 1:n_ofdm_syms
        I_pseudo_deint_syms_array(:, r) = vidwifi_unshuffle(I_deint_array(:, r));
        P_pseudo_deint_syms_array(:, r) = vidwifi_unshuffle(P_deint_array(:, r));
    end
    
end



