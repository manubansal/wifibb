function branch_metrics = wifi_branch_metrics_half_rate(coded_softbits)
  bits = coded_softbits(:);
  abits = coded_softbits(1:2:end);
  bbits = coded_softbits(2:2:end);
  apb = abits + bbits;
  amb = abits - bbits;
  bms = [apb amb].';
  branch_metrics = bms(:);
end
