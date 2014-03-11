function test_wifi_vdec()
  %test1()
  test2()
end

function test1()
  nbits = 6;
  scale = 2^nbits - 1;

  msg_len = 8000;
  tail = zeros(6,1);
  message = randi([0,1],msg_len,1);
  tailed_message = [message; tail];

  coded_message = wifi_cenc(tailed_message);
  coded_message_soft_bits = coded_message * scale;

  tblen = 36;
  %function [ dmsg ] = wifi_vdec(incode, nbits, tblen, initmetric, initstates, initinputs)
  decoded_message = wifi_vdec(coded_message_soft_bits, nbits, tblen);
  decoded_message_no_tail = decoded_message(1:end-6, 1);

  n_bit_err = sum(abs(decoded_message_no_tail - message));
  ber = n_bit_err/msg_len
end


function test2()
  nbits = 6;
  scale = 2^nbits - 1;

  msg_len = 8000;
  tail = zeros(6,1);
  message = randi([0,1],msg_len,1);
  tailed_message = [message; tail];

  coded_message_with_tail = wifi_cenc(tailed_message);
  coded_message_with_tail_soft_bits = coded_message_with_tail * scale;

  coded_message = wifi_cenc(message);
  coded_message_soft_bits = coded_message * scale;

  %chunksize = 0;
  chunksize = 54;
  %tblen = 18;
  tblen = 36;
  %%decoded_message = wifi_vdec(coded_message_soft_bits, nbits, tblen, 'cont', [], [], []);
  %decoded_message = wifi_vdec(coded_message_with_tail_soft_bits, nbits, tblen, 'trunc', [], [], []);
  %decoded_message_no_tail = decoded_message(1:end-6, 1);
  %decoded_message = wifi_vdec(coded_message_soft_bits, nbits, tblen, 'trunc', chunksize, msg_len, [], [], []);
  %decoded_message_no_tail = decoded_message;
  decoded_message = wifi_vdec(coded_message_with_tail_soft_bits, nbits, tblen, 'trunc', chunksize, msg_len);
  decoded_message_no_tail = decoded_message(1:end-6, 1);

  n_bit_err = sum(abs(decoded_message_no_tail - message));
  ber = n_bit_err/msg_len
end
