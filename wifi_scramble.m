function [scrambled_bits scr_seq] = wifi_scramble(databits, initstate)
  if (nargin < 2)
    initstate = randint(1,7);
  end

  %wifi scrambling function: S(x) = x7 + x4 + 1, where x7 is 
  %the oldest in the 7-length shift register
  %scrl = 10;
  scrl = 127;
  %whos
  dbd = databits;
  databits = int16(databits);
  %whos
  %databits(1:7,1)
  %diff = norm(databits - dbd)
  %pause
  %shreg = databits(1:7, 1)
  shreg = initstate;
  %pause
  x = [];
  for i = 1:scrl
    x(end+1) = shreg(1) + shreg(4);
    shreg(end+1) = x(end);
    shreg(1) = [];
  end
  %x
  x = mod(x,2);
  lx = length(x);
  n = length(databits);
  idx = mod(0:(n-1),scrl) + 1;
  scr(1:n) = x(idx);
  if (size(databits, 2) == 1)
    scr = scr';
  end
  %scr = scr
  scr_seq = scr;
  %pause
  scrambled_bits = xor(databits, scr);
end
