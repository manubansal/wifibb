
function [t] = wifi_deinterleaveTables()
  %ncbps = 48, 96, 192, 288
  %nbpsc = 1, 2, 4, 6

  t.bpsk = table(48, 1);
  t.qpsk = table(96, 2);
  t.qam16 = table(192, 4);
  t.qam64 = table(288, 6);

  %sort(t.64qam(:,2))
end

%j - rx index
%k - deinterleave index
%
%i = s × floor(j/s) + (j + floor(16 × j/NCBPS)) mod s,     j = 0,1,… NCBPS – 1 (17-18)
%k = 16 × i – (NCBPS – 1)floor(16 × i/NCBPS) i = 0,1,… NCBPS – 1 (17
%
%s = max(NBPSC/2,1)
function t = table(NCBPS, NBPSC)
  j = (0:(NCBPS-1))';
  s = max(NBPSC/2,1);
  i = s * floor(j/s) + mod((j + floor(16 * j/NCBPS)), s);
  k = 16 * i - (NCBPS - 1) * floor(16 * i/NCBPS);
  j = j + 1; k = k + 1;
  t = [j k];
end
