
function [ndbps, rt120, ncbps, nbpsc, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameters(rate)
  if (rate == 0)
    ndbps = 0;
    rt120 = 0;
    ncbps = 0;
    nbpsc = 0;
  else
    rate_v = [6, 9, 12, 18, 24, 36, 48, 54];

    ndbps_v = [24, 36, 48, 72, 96, 144, 192, 216];
    ncbps_v = [48, 48, 96, 96, 192, 192, 288, 288];
    nbpsc_v = [1, 1, 2, 2, 4, 4, 6, 6];
    rt120_v = [60, 90, 60, 90, 60, 90, 80, 90];

    ri = find(rate_v == rate);
    ndbps = ndbps_v(ri);
    ncbps = ncbps_v(ri);
    nbpsc = nbpsc_v(ri);
    rt120 = rt120_v(ri);
  end

  %------ data and pilot subcarrier indices ------
  nsubc = 64; 									%number of subcarriers
  psubc_idx = (nsubc/2)+[(1+[-21 -7 7 21])];					%regular order (dc in middle)
  %pause

  d1subc_idx = (nsubc/2)+[(1+[-32 -1 1 31])];					%regular order (dc in middle)
  dsubc_idx = (nsubc/2)+[(1+[-26:-22 -20:-8 -6:-1]) (1+[1:6 8:20 22:26])];	%regular order (dc in middle)
  %-------------------------------------------------
end
