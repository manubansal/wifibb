function retrieve_array = vidwifi_unshuffle(out_array)
% undos vidwifi_shuffle - (out_array)
    
    np_cbps = length(out_array);
    temp = reshape(out_array, [], 16);
    temp = temp';
    retrieve_array = reshape(temp, np_cbps, 1);
%     sum(abs(retrieve_array - in_array))
end

