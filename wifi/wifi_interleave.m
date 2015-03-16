function [interleaved_bits j] = wifi_interleave(cmp, coded_bits, N_CBPS)
  %common_params = wifi_common_parameters({});
  common_params = cmp;
  %Each modulation rate (bpsk, qpsk, 16qam, 64qam) allows this many bits per
  %subcarrier:
%   Number_of_coded_bits_per_symbol_options = [ 48, 96, 192, 288];

  %Index definitions for the four options:
%   BPSK = 1; QPSK = 2; QAM16 = 3; QAM64 = 4;

  %By default, script generates the 64QAM look up table:
%   if (nargin < 2)
%     N_CBPS=Number_of_coded_bits_per_symbol_options(QAM16); 
%   end

  %Generate additional necessary parameters per the 802.11 specification:
  N_BPSC=N_CBPS/common_params.ndatasubc;
  s=max(N_BPSC/2,1);

  %initial indices
  %k=0:N_CBPS-1;
  k=(0:N_CBPS-1)';

  %first wifi interleaving permutation
  i= (N_CBPS/16) * mod(k,16) + floor(k./16);

  %second permutation
  j = s*floor(i./s) + mod((i + N_CBPS - floor(16.*i./N_CBPS)),s);

  %interleave them
  %interleaved_bits(j+1) = coded_bits;
  j = j + 1;
  interleaved_bits(j,:) = coded_bits;

  %%interleaved_bits = reshape(interleaved_bits, prod(size(interleaved_bits)), 1);

  %coded_bits_unpacked = convert_bits_to_unpacked(coded_bits);
  %interleaved_bits_unpacked = convert_bits_to_unpacked(interleaved_bits);
  %
  %coded_bits_cstyle = convert_cell_array_to_cstyle(coded_bits_unpacked)
  %interleaved_bits_cstyle = convert_cell_array_to_cstyle(interleaved_bits_unpacked)
end
