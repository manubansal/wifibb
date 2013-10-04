function [mapped_syms, databits_i_all, databits_q_all] = wifi_tx_chain_inner(msg_scr, rate)
  [ndbps, rt120, ncbps, nbpsc] = wifi_parameters(rate)
  n_ofdm_syms = length(msg_scr)/ndbps;
  %pause

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% code the entire message (with service, tail and pad) and also
  %% puncture it according to the coding rate
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  msg_code = wifi_cenc(msg_scr, rt120);
  %coded_message_soft_bits = coded_message * scale;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% arrange coded bits as symbols
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  msg_code_syms = reshape(msg_code, ncbps, n_ofdm_syms);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% interleave the bits
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  msg_int_syms = wifi_interleave(msg_code_syms, ncbps);

  %msg_int_syms = msg_int_syms
  %n_ofdm_syms = n_ofdm_syms
  %size(msg_int_syms)
  %pause

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% map bits onto constellation symbols
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  mapped_syms = [];
  databits_i_all = [];
  databits_q_all = [];
  for i = 1:n_ofdm_syms
    [mapped_sym, databits_i, databits_q] = wifi_map(msg_int_syms(:,i), nbpsc)
    mapped_syms = [mapped_syms mapped_sym];
    databits_i_all = [databits_i_all databits_i];
    databits_q_all = [databits_q_all databits_q];
  end

  %s0 = size(mapped_syms)
  %pause
end
