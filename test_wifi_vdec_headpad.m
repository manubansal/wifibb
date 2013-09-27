function test_wifi_vdec_headpad()
  %test_regular()
  %test_headpad_1()
  test_headpad_2()
end

function test_regular()
  display('test_regular');
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


function test_headpad_1()
  display('test_headpad');
  nbits = 6;
  scale = 2^nbits - 1;

  msg_len = 500;
  tblen = 36;
  head_len = tblen;

  tail = zeros(6,1);

  message = randint(msg_len,1);
  tailed_message = [message; tail];

  code_headpad = zeros(2 * head_len, 1);	%factor of two because coding rate is 1/2
  coded_message = wifi_cenc(tailed_message);
  %coded_message = [code_headpad; message; tail];	%add the headpad too
  coded_message = [code_headpad; coded_message];	%add the headpad too
  coded_message_soft_bits = coded_message * scale;

  %function [ dmsg ] = wifi_vdec(incode, nbits, tblen, initmetric, initstates, initinputs)
  decoded_message = wifi_vdec(coded_message_soft_bits, nbits, tblen);
  decoded_message_no_tail = decoded_message(1:end-6, 1);
  decoded_message_no_tail_no_headpad = decoded_message_no_tail(head_len+1:end, 1);

  size(decoded_message_no_tail_no_headpad)
  size(message)

  %n_bit_err = sum(abs(decoded_message_no_tail - message));
  n_bit_err = sum(abs(decoded_message_no_tail_no_headpad - message));
  ber = n_bit_err/msg_len
end



function test_headpad_2()
  display('test_headpad');
  nbits = 6;
  scale = 2^nbits - 1;

  msg_len = 500;
  tblen = 36;
  head_len = tblen;

  tail = zeros(6,1);

  message = randint(msg_len,1);
  tailed_message = [message; tail];
  headpad = zeros(tblen, 1);	%factor of two because coding rate is 1/2
  headpad_tailed_message = [headpad; tailed_message];

  %coded_message = wifi_cenc(tailed_message);
  coded_message = wifi_cenc(headpad_tailed_message);
  coded_message_soft_bits = coded_message * scale;

  %function [ dmsg ] = wifi_vdec(incode, nbits, tblen, initmetric, initstates, initinputs)
  decoded_message = wifi_vdec(coded_message_soft_bits, nbits, tblen);
  decoded_message_no_tail = decoded_message(1:end-6, 1);
  decoded_message_no_tail_no_headpad = decoded_message_no_tail(head_len+1:end, 1);

  size(decoded_message_no_tail_no_headpad)
  size(message)

  %n_bit_err = sum(abs(decoded_message_no_tail - message));
  n_bit_err = sum(abs(decoded_message_no_tail_no_headpad - message));
  ber = n_bit_err/msg_len
end


