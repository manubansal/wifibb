
%----------------------------------------------------------------------------------------------------------------------------
function tx_pilot_syms = generate_pilot_syms(datalength_nsyms)
%----------------------------------------------------------------------------------------------------------------------------
  %pilot generative code

  nsubc = 64;

  % Pilot Subcarrier Sequence Generator %
  pilot_sc=[ 1,1,1,1, -1,-1,-1,1, -1,-1,-1,-1, 1,1,-1,1, -1,-1,1,1,...
      -1,1,1,-1, 1,1,1,1, 1,1,-1,1, 1,1,-1,1, 1,-1,-1,1, 1,1,-1,1, ...
      -1,-1,-1,1, -1,1,-1,-1, 1,-1,-1,1, 1,1,1,1, -1,-1,1,1,...
      -1,-1,1,-1, 1,-1,1,1, -1,-1,-1,1, 1,-1,-1,-1, -1,1,-1,-1, ...
      1,-1,1,1, 1,1,-1,1, -1,1,-1,1, -1,-1,-1,-1, -1,1,-1,1, 1,-1,1,-1,...
      1,1,1,-1, -1,1,-1,-1, -1,1,1,1, -1,-1,-1,-1, -1,-1,-1 ];

  pilot_sc_ext = [pilot_sc pilot_sc pilot_sc pilot_sc pilot_sc]; %127 * 5 = 635 long - enough for all packet lengths

  if nargin < 1
    datalength_nsyms = length(pilot_sc_ext);
  end

  psubc_idx = (nsubc/2)+[(1+[-21 -7 7 21])];	%regular order (dc in middle)
  psubc_ind = zeros(nsubc,1);
  psubc_ind(psubc_idx) = 1;
  %[psubc_ind [1:64]']
  %%%psubc_ind_shifted = fftshift(psubc_ind)
  %%%psubc_idx_shifted = find(psubc_ind_shifted)     %[8; 22; 44; 58]

  % pilot symbols to load on the above indices: [1 -1 1 1] * polarity, (corresponding 
  % to [1 1 1 -1] * polarity in natural order)

  %%%pilotsyms = diag([1 -1 1 1]) * ones(4, datalength_nsyms);
  pilotsyms = diag([1 1 1 -1]) * ones(4, datalength_nsyms);

  polarity = pilot_sc_ext(1:datalength_nsyms);
  pilotsyms = pilotsyms * diag(polarity);
  %%%fpsyms = zeros(nsubc, datalength_nsyms);
  %%%fpsyms(psubc_idx_shifted, :) = pilotsyms

  tx_pilot_syms = pilotsyms;
end

