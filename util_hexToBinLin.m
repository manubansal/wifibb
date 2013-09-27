
%msg: hexadecimal column vector to be converted to a binary numeric column vector
%with wifi convention where the lsb comes first in the output order.
function [msg_bin_lin  msg_len] = util_hexToBinLin(msg)
  length_msg = length(msg);
  msg_dec = hex2dec(msg);
  %msg_bin = (dec2bin(msg_dec, 8)' == '1')
  msg_bin = (dec2bin(msg_dec, 8) == '1');
  msg_bin = fliplr(msg_bin)';	%lsb msb order flip
  msg_bin_lin = reshape(msg_bin, prod(size(msg_bin)), 1);
  msg_len = length(msg_bin_lin);
end
