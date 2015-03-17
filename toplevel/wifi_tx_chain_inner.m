function [mapped_syms, databits_i_all, databits_q_all] = wifi_tx_chain_inner(cmp, msg_scr, rate, rate_chart, plcp_or_data, confStr, tx_params)
  [ndbps, rt120, ncbps, nbpsc] = wifi_parameter_parser(cmp, rate, rate_chart);
  n_ofdm_syms = length(msg_scr)/ndbps;
  %pause

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% code the entire message (with service, tail and pad) and also
  %% puncture it according to the coding rate
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if tx_params.dumpVars_preConvBits
    util_dumpData(strcat(plcp_or_data, 'PreConvBits'), confStr, msg_scr);
  end
  
  msg_code = wifi_cenc(msg_scr, rt120);
  
  msg_code_dump = msg_code * 255;
  if tx_params.dumpVars_convBits
    util_dumpData(strcat(plcp_or_data, 'ConvBits'), confStr, msg_code_dump);
  end
  %coded_message_soft_bits = coded_message * scale;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% arrange coded bits as symbols
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  msg_code_syms = reshape(msg_code, ncbps, n_ofdm_syms);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% interleave the bits
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %util_dumpData('interleaver48_in', confStr, msg_code_syms);
  msg_int_syms = wifi_interleave(cmp,msg_code_syms, ncbps);
  %util_dumpData('interleaver48_out', confStr, msg_int_syms);

  %msg_int_syms = msg_int_syms
  %n_ofdm_syms = n_ofdm_syms
  %size(msg_int_syms)
  %pause

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% map bits onto constellation symbols
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  msg_int_syms_dump = msg_int_syms * 255;
  if tx_params.dumpVars_interleavedBits
    util_dumpData(strcat(plcp_or_data, 'InterleavedBits'), confStr, msg_int_syms_dump);
  end
  
  mapped_syms = [];
  databits_i_all = [];
  databits_q_all = [];
  for i = 1:n_ofdm_syms
    [mapped_sym, databits_i, databits_q] = wifi_map(msg_int_syms(:,i), nbpsc);
    mapped_syms = [mapped_syms mapped_sym];
    databits_i_all = [databits_i_all databits_i];
    databits_q_all = [databits_q_all databits_q];
  end
  
  mapped_syms_dump = mapped_syms * (2^12); % because Q12 expected in orsys
  if tx_params.dumpVars_mappedSymbols
    util_dumpData(strcat(plcp_or_data, 'MappedSymbols'), confStr, mapped_syms_dump);
  end

  %s0 = size(mapped_syms)
  %pause

end
