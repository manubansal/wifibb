
function [t] = wifi_deinterleaveTables(cmp)
  %ncbps = 48, 96, 192, 288
  %nbpsc = 1, 2, 4, 6
  [~, ~, ncbps_bpsk, nbpsc_bpsk, ~, ~, ~, ~] = wifi_parameter_parser(cmp, 6);
  [~, ~, ncbps_qpsk, nbpsc_qpsk, ~, ~, ~, ~] = wifi_parameter_parser(cmp, 12);
  [~, ~, ncbps_qam16, nbpsc_qam16, ~, ~, ~, ~] = wifi_parameter_parser(cmp, 24);
  [~, ~, ncbps_qam64, nbpsc_qam64, ~, ~, ~, ~] = wifi_parameter_parser(cmp, 48);
  
  t.bpsk = table(ncbps_bpsk, nbpsc_bpsk);
  t.qpsk = table(ncbps_qpsk, nbpsc_qpsk);
  t.qam16 = table(ncbps_qam16, nbpsc_qam16);
  t.qam64 = table(ncbps_qam64, nbpsc_qam64);

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
