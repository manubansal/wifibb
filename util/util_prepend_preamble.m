function td_pkt_samples = util_prepend_preamble(cmp, td_data_samples, confStr, tx_params, cplen)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Generate preamble portions
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %opt = {};
  %opt = wifi_common_parameters(opt);
  opt = cmp;

  stf_len = opt.stf_len;
  ltf_len = opt.ltf_len;
  								%extra sample due to windowing. this makes the length exactly match up.
  [ig1, ig2, stf_sync_total] = wifi_shortTrainingField(cmp);
  ltf_sync_total = wifi_longTrainingField(cmp, cplen);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Join stf and ltf
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [[stf_sync_total; zeros(ltf_len,1)] [zeros(stf_len,1); ltf_sync_total]];
  %pause

  
  stf_ltf_sync_total = [ stf_sync_total; zeros(ltf_len,1)] + [zeros(stf_len,1); ltf_sync_total];
  
  % scale floats to 16 bit fixed
  stf_ltf_sync_total_dump = round(stf_ltf_sync_total*(2^12));
  if tx_params.dumpVars_stfLtf
    util_dumpData('stfLtfSyncTotal', confStr, stf_ltf_sync_total_dump);
  end
  

  %size(stf_ltf_sync_total)
  %pause


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Join preamble and data
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % stf_ltf_sync_total is 321 samples long
  % td_data_samples is to be joined by overlapping the 321'st sample of preamble

  td_pkt_samples = [stf_ltf_sync_total(1:end-1); td_data_samples];
  td_pkt_samples(stf_len+ltf_len+1) = td_pkt_samples(stf_len+ltf_len+1) + stf_ltf_sync_total(stf_len+ltf_len+1);
  %size(td_pkt_samples)
  %pause
end
