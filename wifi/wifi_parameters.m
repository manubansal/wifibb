
function [ndbps, rt120, ncbps, nbpsc] = wifi_parameters(rate)
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
