
function [ndbps, rt120, ncbps, nbpsc, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameters(rate)
  common_params = wifi_common_parameters({});
  if (rate == 0)
    ndbps = 0;
    rt120 = 0;
    ncbps = 0;
    nbpsc = 0;
  else
    nbpsc_v = [1, 1, 2, 2, 4, 4, 6, 6];
    rt120_v = [60, 90, 60, 90, 60, 90, 80, 90];
    ncbps_v = nbpsc_v*common_params.ndatasubc;
    ndbps_v = ncbps_v.*rt120_v/120;
    
    rate_v = ndbps_v/(common_params.sample_duration_sec*common_params.sym_len_s*10^6);

    ri = find(rate_v == rate);
    ndbps = ndbps_v(ri);
    ncbps = ncbps_v(ri);
    nbpsc = nbpsc_v(ri);
    rt120 = rt120_v(ri);
  end

  %------ data and pilot subcarrier indices ------
  
  nsubc = common_params.nsubc; 									%number of subcarriers
  psubc_idx = common_params.psubc_idx;					%regular order (dc in middle)
  %pause

  d1subc_idx = common_params.d1subc_idx;					%regular order (dc in middle)
  dsubc_idx = common_params.dsubc_idx;	%regular order (dc in middle)
  %-------------------------------------------------
end
