function test_wifi_vdec_headpad()
  %test_regular()
  %test_headpad_overly_cautious()
  %%test_headpad_the_correct_version()
  %%test_headpad_with_trace()
  test_alternate_tailed_version()
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


function test_headpad_overly_cautious()
  display('test_headpad_overly_cautious');
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



function test_headpad_the_correct_version()
  display('test_headpad_the_correct_version');
  nbits = 6;	%for softbit scale
  scale = 2^nbits - 1;

  msg_len = 500;  %in bits
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


%Reference test cases for test_mid_convgt and test_mid_convgt_tailed DSP unittests.
function test_headpad_with_trace()
  display('test_headpad_with_trace');
  nbits = 6;	%for softbit scale
  scale = 2^nbits - 1;

  msg_len = 32;  %size of message without tail or headpad, in bits
  %message = randint(msg_len,1);
  msg_hex = '4E59D18F';
  message = fliplr(de2bi(hex2dec(msg_hex),msg_len));	%because de2bi returns lsb first
  message = message(:);

  tblen = 36;
  head_len = tblen;

  tail = zeros(6,1);

  tailed_message = [message; tail];

  %headpad = zeros(tblen, 1);	
  %headpad = randint(tblen, 1);	
  headpad_hex='232425267'
  headpad = fliplr(de2bi(hex2dec(headpad_hex),tblen));	%because de2bi returns lsb first
  headpad = headpad(:);

  tailpad_hex='5918AC2B9'
  tailpad = fliplr(de2bi(hex2dec(tailpad_hex),tblen));	%because de2bi returns lsb first
  tailpad = tailpad(:);


  headpad_tailed_message = [headpad; tailed_message];

  headpad_tailpad_message = [headpad; message; tailpad];

  %encode message
  coded_message = wifi_cenc(headpad_tailed_message);
  coded_message_soft_bits = coded_message * scale;
  coded_message_tailpad = wifi_cenc(headpad_tailpad_message);
  coded_message_tailpad_soft_bits = coded_message_tailpad * scale;



  %------ reference test data --------------
  %soft branch metrics - for trace
  coded_message_soft_bits_ti = coded_message_soft_bits - (2^(nbits - 1));
  coded_message_soft_bits_ti = -coded_message_soft_bits_ti;			%because ti maps 0 -> 1 and 1 -> -1
  branch_metrics = wifi_branch_metrics_half_rate(coded_message_soft_bits_ti);
  [coded_message_soft_bits coded_message_soft_bits_ti branch_metrics]			%branch_metric is the test data vector
  pause

  %soft branch metrics with tailpad - for trace
  coded_message_tailpad_soft_bits_ti = coded_message_tailpad_soft_bits - (2^(nbits - 1));
  coded_message_tailpad_soft_bits_ti = -coded_message_tailpad_soft_bits_ti;	%because ti maps 0 -> 1 and 1 -> -1
  branch_metrics = wifi_branch_metrics_half_rate(coded_message_tailpad_soft_bits_ti);
  [coded_message_tailpad_soft_bits coded_message_tailpad_soft_bits_ti branch_metrics]	%branch_metric is the test data vector
  pause
  %------ reference test data --------------


  %decode message
  decoded_message = wifi_vdec(coded_message_soft_bits, nbits, tblen);
  decoded_message_no_tail = decoded_message(1:end-6, 1);
  decoded_message_no_tail_no_headpad = decoded_message_no_tail(head_len+1:end, 1);

  size(decoded_message_no_tail_no_headpad)
  size(message)

  %n_bit_err = sum(abs(decoded_message_no_tail - message));
  n_bit_err = sum(abs(decoded_message_no_tail_no_headpad - message));
  ber = n_bit_err/msg_len
end



function test_alternate_tailed_version()
  display('test_alternate_tailed_version');
  nbits = 6;	%for softbit scale
  scale = 2^nbits - 1;

  msg_len = 32;  %size of message without tail or headpad, in bits
  %message = randint(msg_len,1);
  msg_hex = '4E59D18F';
  message = fliplr(de2bi(hex2dec(msg_hex),msg_len));	%because de2bi returns lsb first
  message = message(:);

  tblen = 36;
  head_len = tblen;

  taillen = 6;
  tail = zeros(taillen,1);

  extlen = tblen - taillen;
  extended_tail = zeros(extlen, 1);

  extended_tailed_message = [message; tail; extended_tail];

  headpad_hex='232425267'
  headpad = fliplr(de2bi(hex2dec(headpad_hex),tblen));	%because de2bi returns lsb first
  headpad = headpad(:);

  headpad_extended_tailed_message = [headpad; extended_tailed_message];

  %encode message
  coded_message = wifi_cenc(headpad_extended_tailed_message);
  %coded_extension = coded_message(end-extlen*2+1:end)
  %pause
  coded_message_soft_bits = coded_message * scale;


  %------ reference test data --------------
  %soft branch metrics - for trace
  coded_message_soft_bits_ti = coded_message_soft_bits - (2^(nbits - 1));
  coded_message_soft_bits_ti = -coded_message_soft_bits_ti;			%because ti maps 0 -> 1 and 1 -> -1
  branch_metrics = wifi_branch_metrics_half_rate(coded_message_soft_bits_ti);
  [coded_message_soft_bits coded_message_soft_bits_ti branch_metrics]			%branch_metric is the test data vector
  pause
  %------ reference test data --------------


  %decode message
  decoded_message = wifi_vdec(coded_message_soft_bits, nbits, tblen);
  decoded_message_no_tail_no_ext = decoded_message(1:end-taillen-extlen, 1);
  decoded_message_no_tail_no_ext_no_headpad = decoded_message_no_tail_no_ext(head_len+1:end, 1);

  size(decoded_message_no_tail_no_ext_no_headpad)
  size(message)

  %n_bit_err = sum(abs(decoded_message_no_tail - message));
  n_bit_err = sum(abs(decoded_message_no_tail_no_ext_no_headpad - message));
  ber = n_bit_err/msg_len
end

