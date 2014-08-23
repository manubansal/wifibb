function [descrambled_bits descr_seq] = wifi_descramble(databits)
  %wifi scrambling function: S(x) = x7 + x4 + 1, where x7 is 
  %the oldest in the 7-length shift register
  %scrl = 10;
  scrl = 127;
  %whos
  dbd = databits;
  databits = int16(databits);
  %whos
  %%databits(1:7,1)
  %diff = norm(databits - dbd)
  %pause
  shreg = databits(1:7, 1);
  x = shreg;
  for i = 1:(scrl - 7)
    x(end+1) = xor(shreg(1),shreg(4));
    shreg(end+1) = x(end);
    shreg(1) = [];
  end
  %x
  %x = mod(x,2);
  lx = length(x);
  n = length(databits);
  idx = mod(0:(n-1),scrl) + 1;
  scr(1:n) = x(idx);
  if (size(databits, 2) == 1)
    scr = scr';
  end
  %scr = scr
  descr_seq = scr;
  %pause
  descrambled_bits = xor(databits, scr);
end
