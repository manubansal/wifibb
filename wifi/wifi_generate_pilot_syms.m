
%----------------------------------------------------------------------------------------------------------------------------
function tx_pilot_syms = wifi_generate_pilot_syms(common_params, datalength_nsyms)
%----------------------------------------------------------------------------------------------------------------------------
  %pilot generative code

%  common_params = wifi_common_parameters({});
  nsubc = common_params.nsubc;

  % Pilot Subcarrier Sequence Generator %
  pilot_sc=common_params.pilot_sc;
  
  pilot_sc_ext = [pilot_sc pilot_sc pilot_sc pilot_sc pilot_sc]; %127 * 5 = 635 long - enough for all packet lengths

  if nargin < 2
    datalength_nsyms = length(pilot_sc_ext);
  end

  psubc_idx = common_params.psubc_idx;	%regular order (dc in middle)
  psubc_ind = zeros(nsubc,1);
  psubc_ind(psubc_idx) = 1;
  %[psubc_ind [1:64]']
  %%%psubc_ind_shifted = fftshift(psubc_ind)
  %%%psubc_idx_shifted = find(psubc_ind_shifted)     %[8; 22; 44; 58]

  % pilot symbols to load on the above indices: [1 -1 1 1] * polarity, (corresponding 
  % to [1 1 1 -1] * polarity in natural order)

  %%%pilotsyms = diag([1 -1 1 1]) * ones(4, datalength_nsyms);
  pilotsyms = diag(fftshift(common_params.intrasym_pilot_sc)) * ones(common_params.npsubc, datalength_nsyms);

  polarity = pilot_sc_ext(1:datalength_nsyms);
  pilotsyms = pilotsyms * diag(polarity);
  %%%fpsyms = zeros(nsubc, datalength_nsyms);
  %%%fpsyms(psubc_idx_shifted, :) = pilotsyms

  tx_pilot_syms = pilotsyms;
end

