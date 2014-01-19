function td_pkt_samples = util_prepend_preamble(td_data_samples, confStr)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Generate preamble portions
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  								%extra sample due to windowing. this makes the length exactly match up.
  [ig1, ig2, stf_sync_total] = wifi_shortTrainingField();
  ltf_sync_total = wifi_longTrainingField();

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Join stf and ltf
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [[stf_sync_total; zeros(160,1)] [zeros(160,1); ltf_sync_total]];
  %pause

  
  stf_ltf_sync_total = [ stf_sync_total; zeros(160,1)] + [zeros(160,1); ltf_sync_total];
  
  % scale floats to 16 bit fixed
  stf_ltf_sync_total_dump = round(stf_ltf_sync_total*(2^12));
  util_dumpData('stfLtfSyncTotal', confStr, stf_ltf_sync_total_dump);
  

  %size(stf_ltf_sync_total)
  %pause


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Join preamble and data
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % stf_ltf_sync_total is 321 samples long
  % td_data_samples is to be joined by overlapping the 321'st sample of preamble

  td_pkt_samples = [stf_ltf_sync_total(1:end-1); td_data_samples];
  td_pkt_samples(321) = td_pkt_samples(321) + stf_ltf_sync_total(321);
  %size(td_pkt_samples)
  %pause
end
