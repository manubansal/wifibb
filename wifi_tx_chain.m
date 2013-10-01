
function [samples_f, n_ofdm_syms, databits_i_all, databits_q_all] = wifi_tx_chain(msg, rate)
  base_msg = msg
  base_msg_len_bits = length(base_msg)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% configure parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  [ndbps, rt120, ncbps, nbpsc] = wifi_parameters(rate)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% prepare the message with service, tail and pad bits
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  service = zeros(16,1);
  tail = zeros(6,1);
  msg = [service; msg; tail];

  npad = ceil(length(msg)/ndbps) * ndbps - length(msg);
  pad = zeros(npad,1);
  msg = [msg; pad];

  n_ofdm_syms = length(msg)/ndbps

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% scramble the message
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  src_initstate = [1 0 1 1 1 0 1];
  [msg_scr scr_seq] = wifi_scramble(msg, src_initstate);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% zero-out tail portion after scrambling
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  msg_scr(16 + base_msg_len_bits + 1:16 + base_msg_len_bits + 6) = 0;


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

  msg_int_syms = msg_int_syms
  n_ofdm_syms = n_ofdm_syms
  size(msg_int_syms)
  pause

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
  samples_f = reshape(mapped_syms, prod(size(mapped_syms)), 1);
end
