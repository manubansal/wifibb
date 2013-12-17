function out_array = vidwifi_shuffle(in_array)
% in_array is necessarily a vector with size being multiple of 48
% in particular, it can be either of [48, 96, 144, 192, 240, 288]
    
    % in_array = [1:96]';
    % np_cbps = 96;
    
    % Each ofdm symbol has 48 subcarriers
    nsc_ps = 48;
    np_cbps = length(in_array);
    assert(rem(np_cbps, nsc_ps) == 0, 'Length of pseudo vector is not a multiple of 48.')
    
    temp = reshape(in_array, 16, []);   % mimics actual interleaving
    temp = temp';
    out_array = reshape(temp, np_cbps, 1);
end
