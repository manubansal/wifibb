
function test_wifi_softSlice
  test2
end

function test1
  points = [...
  1+i;...
  3+i;...
  5+i;...
  7+i;...
  8+i;...
  ];

  points = points/sqrt(42);

  ncbps = 6;
  nbits = 6;

  softbits = wifi_softSlice(points, ncbps, nbits);

  threshold = 2^(nbits - 1);

  hardbits = softbits > threshold;

  [softbits hardbits]

  n_soft_bits = length(softbits)
end



function test2
  rand('seed',3)

  %n_bit = 288;
  n_bit = 576;	%lcm of 288, 192, 96, 48

  %Generate random bitstream:
  input_bits = round(rand(n_bit,1));

  points_o_64 = wifi_mapper_map64qam(input_bits);
  points_o_16 = wifi_mapper_map16qam(input_bits);
  points_o_qp = wifi_mapper_mapqpsk(input_bits);
  points_o_bp = wifi_mapper_mapbpsk(input_bits);

  snrs = [25 20 15 10 5 3 2 0];	%db
  nbits = 6;

  %stat out 64-qam
  ncbps = 6;
  bers64 = snr_ber_stats(points_o_64, ncbps, nbits, input_bits, snrs);

  %stat out 16-qam
  ncbps = 4;
  bers16 = snr_ber_stats(points_o_16, ncbps, nbits, input_bits, snrs);

  %stat out qpsk
  ncbps = 2;
  bersqp = snr_ber_stats(points_o_qp, ncbps, nbits, input_bits, snrs);

  %stat out 16-qam
  ncbps = 1;
  bersbp = snr_ber_stats(points_o_bp, ncbps, nbits, input_bits, snrs);

  snr_vs_ber = [snrs; bers64; bers16; bersqp; bersbp]
end

function [bers] = snr_ber_stats(points_o, ncbps, nbits, input_bits, snrs) 
  n_bit = length(input_bits);
  bers = [];
  for i = 1:length(snrs)
    snr = snrs(i);
    points = awgn(points_o, snr, 'measured');

    softbits = wifi_softSlice(points, ncbps, nbits);
    %n_soft_bits = length(softbits)

    threshold = 2^(nbits - 1);
    hardbits = softbits > threshold;

    errvec = input_bits - hardbits;
    [input_bits softbits hardbits errvec]
    n_bit_err = sum(abs(errvec))
    ber = n_bit_err/n_bit
    bers(end+1) = ber;
  end
end
