function test_wifi_vdec()
  %test1()
  test2()
end

function test1()
  nbits = 6;
  scale = 2^nbits - 1;

  msg_len = 500;
  tail = zeros(6,1);
  message = randint(msg_len,1);
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

