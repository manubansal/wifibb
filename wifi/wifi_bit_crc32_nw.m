
% ! does_not_work !
%non-working
function crc_val = wifi_bit_crc32_nw(msg_bin_lin)  
  %G(x) = x32 + x26 + x23 + x22 + x16 + x12 + x11 + x10 + x8 + x7 + x5 + x4 + x2 + x + 1
  gx = zeros(1,32);
  gx([32 26 23 22 16 12 11 10 8 7 5 4 2 1]) = 1;
  gx = [1 gx];	%for x0
  gx = fliplr(gx);
  %[32:-1:0; gx]'

  h = crc.generator(gx);

  msg_w_crc = generate(h, msg_bin_lin);
  crc_val = msg_w_crc(end-32+1:end)
end



