function td_data_samples = wifi_time_domain_windowing(tdsyms_w_cp, tdsyms)
  nsyms = size(tdsyms, 2)

  extra_for_windowing = tdsyms(1, :);
  tdsyms_w_cp = [tdsyms_w_cp; extra_for_windowing];

  %window the data
  w = [0.5 ones(1,79) 0.5]';
  tdsyms_w_cp = diag(w) * tdsyms_w_cp;

  row_to_add = [0 tdsyms_w_cp(end,:)];
  tdsyms_w_cp(:,end+1) = zeros(size(tdsyms_w_cp,1), 1);
  tdsyms_w_cp(1,:) = tdsyms_w_cp(1,:) + row_to_add;
  tdsyms_w_cp(end,:) = [];
  %size_after_windowing = size(tdsyms_w_cp)
  %pause

  %collapse into a single column of samples
  %tdsyms = reshape(tdsyms_w_cp, size(tdsyms_w_cp,1) * nsyms + 1, 1)
  td_data_samples = reshape(tdsyms_w_cp, prod(size(tdsyms_w_cp)), 1);
  %size_after_reshape_1 = size(td_data_samples)
  %pause

  td_data_samples = td_data_samples(1:size(tdsyms_w_cp,1) * nsyms + 1);
  %size_after_reshape_2 = size(td_data_samples)
  %pause
end
