
function [samples_f, n_ofdm_syms, databits_i_all, databits_q_all, datasyms, td_data_samples, td_pkt_samples, msg_scr] = wifi_tx_chain(smp, txp, cmp, msg, rate, confStr, cplen, use_length_field_for_seq_no, seqno)
  if nargin < 8
    use_length_field_for_seq_no = 0;
    seqno = -1;
  end

  %sim_params = default_sim_parameters();
  %tx_params = wifi_tx_parameters();
  sim_params = smp;
  tx_params = txp;

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
  rate_sig = sim_params.rate_sig;
  rate_chart = sim_params.rate_chart;
  if use_length_field_for_seq_no
    display(['using length field for seq no, base_msg_len_bytes = ' num2str(base_msg_len_bytes)])
    if (seqno >= 2^12)
      jj = mod(seqno, 2^12);
      warning(['seq no. too big to encode in length field, given: ' num2str(seqno) ', using: ' num2str(jj)])
      seqno = jj;
    end
    tx_sig_field = wifi_pack_signal(rate, rate_chart, seqno);
  else
    tx_sig_field = wifi_pack_signal(rate, rate_chart, base_msg_len_bytes);
  end
  %tx_sig_field = wifi_pack_signal(rate, orig_base_msg_len_bytes);
  [ndbps, rt120, ncbps, nbpsc] = wifi_parameter_parser(cmp, rate_sig, rate_chart);
  
  npad = ceil(length(tx_sig_field)/ndbps) * ndbps - length(tx_sig_field);
  pad = zeros(1, npad);
  tx_sig_field = [tx_sig_field pad];

  %n_ofdm_syms_sig = 1;
  %tx_sig_field = tx_sig_field
  %pause
  [sigsym, ig1, ig2] = wifi_tx_chain_inner(cmp, tx_sig_field, rate_sig, rate_chart,'plcp', confStr, tx_params);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% create the data field
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  [ndbps, rt120, ncbps, nbpsc] = wifi_parameter_parser(cmp, rate, rate_chart);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% prepare the message with service, tail and pad bits
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  service = zeros(sim_params.service_bits,1);
  tail = zeros(sim_params.tail_bits,1);
  msg = [service; msg; tail];

  npad = ceil(length(msg)/ndbps) * ndbps - length(msg);

  %npad = npad

  pad = zeros(npad,1);
  msg = [msg; pad];

  n_ofdm_syms = length(msg)/ndbps;
  fprintf(1, 'n_ofdm_syms=%d\n', n_ofdm_syms);
  
  if tx_params.dumpVars_dataBits
    util_dumpData('dataBits', confStr, msg);
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% scramble the message
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  src_initstate = sim_params.scrambler_init;
  %--------------------------------------------------------------------------------------
  [msg_scr scr_seq] = wifi_scramble(msg, src_initstate);
  %--------------------------------------------------------------------------------------

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% zero-out tail portion after scrambling
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  msg_scr(sim_params.service_bits + base_msg_len_bits + 1:sim_params.service_bits + base_msg_len_bits + sim_params.tail_bits) = 0;


  %--------------------------------------------------------------------------------------
  [mapped_syms, databits_i_all, databits_q_all] = wifi_tx_chain_inner(cmp, msg_scr, rate, rate_chart, 'data', confStr, tx_params);
  %--------------------------------------------------------------------------------------

  samples_f = reshape(mapped_syms, prod(size(mapped_syms)), 1);

  %datasyms = mapped_syms
  sa = size(mapped_syms);
  sb = size(sigsym);
  %pause
  datasyms = [sigsym mapped_syms];

  datasyms_dump = datasyms * (2^12); % because Q12 expected in orsys
  if tx_params.dumpVars_mappedSymbols
    util_dumpData('allMappedSymbols', confStr, datasyms_dump);
  end

  %--------------------------------------------------------------------------------------
  [tdsyms_w_cp, tdsyms] = wifi_ofdm_modulate(cmp, datasyms, cplen);
  %--------------------------------------------------------------------------------------

  tdsyms_w_cp_dump = tdsyms_w_cp * (2^12);
  if tx_params.dumpVars_ofdmMod
    util_dumpData('allOfdmMod', confStr, tdsyms_w_cp_dump);
  end

  %--------------------------------------------------------------------------------------
  td_data_samples = wifi_time_domain_windowing(tdsyms_w_cp, tdsyms);
  %--------------------------------------------------------------------------------------

  % add preamble
  %--------------------------------------------------------------------------
  td_pkt_samples = util_prepend_preamble(cmp, td_data_samples, confStr, tx_params, cplen);
  %--------------------------------------------------------------------------
end
