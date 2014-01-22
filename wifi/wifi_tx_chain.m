
function [samples_f, n_ofdm_syms, databits_i_all, databits_q_all, td_data_samples, td_pkt_samples, msg_scr] = wifi_tx_chain(msg, rate, confStr)
  %%%%%%%%%%%%%%
  %% add the crc 
  %%%%%%%%%%%%%%
  msg = wifi_append_crc32(msg);

  base_msg = msg;
  base_msg_len_bits = length(base_msg);
  base_msg_len_bytes = base_msg_len_bits/8;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% create the signal field mapped symbol
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  rate_sig = 6;
  tx_sig_field = wifi_pack_signal(rate, base_msg_len_bytes);
  %tx_sig_field = wifi_pack_signal(rate, orig_base_msg_len_bytes);
  [ndbps, rt120, ncbps, nbpsc] = wifi_parameters(rate_sig);
  %n_ofdm_syms_sig = 1;
  tx_sig_field = tx_sig_field
  %pause
  [sigsym, ig1, ig2] = wifi_tx_chain_inner(tx_sig_field, rate_sig, 'plcp', confStr);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% create the data field
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  [ndbps, rt120, ncbps, nbpsc] = wifi_parameters(rate);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% prepare the message with service, tail and pad bits
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  service = zeros(16,1);
  tail = zeros(6,1);
  msg = [service; msg; tail];

  npad = ceil(length(msg)/ndbps) * ndbps - length(msg);

  npad = npad

  pad = zeros(npad,1);
  msg = [msg; pad];

  n_ofdm_syms = length(msg)/ndbps;
  
  util_dumpData('dataBits', confStr, msg);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% scramble the message
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  src_initstate = [1 0 1 1 1 0 1];
  %--------------------------------------------------------------------------------------
  [msg_scr scr_seq] = wifi_scramble(msg, src_initstate);
  %--------------------------------------------------------------------------------------

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% zero-out tail portion after scrambling
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  msg_scr(16 + base_msg_len_bits + 1:16 + base_msg_len_bits + 6) = 0;


  %--------------------------------------------------------------------------------------
  [mapped_syms, databits_i_all, databits_q_all] = wifi_tx_chain_inner(msg_scr, rate, 'data', confStr);
  %--------------------------------------------------------------------------------------

  samples_f = reshape(mapped_syms, prod(size(mapped_syms)), 1);

  %datasyms = mapped_syms
  sa = size(mapped_syms);
  sb = size(sigsym);
  %pause
  datasyms = [sigsym mapped_syms];

  datasyms_dump = datasyms * (2^12); % because Q12 expected in orsys
  util_dumpData('allMappedSymbols', confStr, datasyms_dump);

  %--------------------------------------------------------------------------------------
  [tdsyms_w_cp, tdsyms] = wifi_ofdm_modulate(datasyms);
  %--------------------------------------------------------------------------------------

  tdsyms_w_cp_dump = tdsyms_w_cp * (2^12);
  util_dumpData('allOfdmMod', confStr, tdsyms_w_cp_dump);

  %--------------------------------------------------------------------------------------
  td_data_samples = wifi_time_domain_windowing(tdsyms_w_cp, tdsyms);
  %--------------------------------------------------------------------------------------

  % add preamble
  %--------------------------------------------------------------------------
  td_pkt_samples = util_prepend_preamble(td_data_samples, confStr);
  %--------------------------------------------------------------------------
end
