%WARNING: This function compute SNR relative to the nearest constellation point. This is 
%going to be correct when nearest constellation point was indeed the transmitted constellation
%point, an assumption which would hold true at high SNRs for that constellation. However, at
%low SNR, this would result in an overstatement of SNR. A more robust blind estimate is one 
%from equalized LTF sequences (preamble), since that is always a known sequence.
function [avgsnr avgsnr_dB snr_vector snr_vector_dB] = util_constellationSNR(points, nbpsc)
  points = points(:);
  npoints = length(points);
  if (nbpsc == 1) %bpsk
      BPSK = [-1, 1];
      map = BPSK;
  elseif (nbpsc == 2) %qpsk
      QPSK = [-1-1j,-1+1j, 1-1j, 1+1j]./sqrt(2);
      map = QPSK;
  elseif (nbpsc == 4) %16qam
      QAM16 = [-3-3j
		  -3-1j
		  -3+3j
		  -3+1j
		  -1-3j
		  -1-1j
		  -1+3j
		  -1+1j
		  +3-3j
		  +3-1j
		  +3+3j
		  +3+1j
		  +1-3j
		  +1-1j
		  +1+3j
		  +1+1j]./sqrt(10);
      map = QAM16.';
  elseif (nbpsc == 6) %64qam
      iq_pattern = [-7,-5,-1,-3,+7,+5,+1,+3];
      QAM64=zeros(8,8);
      for i=1:8
	  for k=1:8
	      QAM64(i,k) = iq_pattern(i) + 1i*iq_pattern(k);
	  end
      end
      QAM64 = reshape(transpose(QAM64),64,1)./sqrt(42);
      map = QAM64.';
  else
    error('Unknown constellation','I dont know how to find the SNR of this constellation');
  end

  %map = map
  nstars = length(map);
  points_rep = repmat(points, 1, nstars);
  map_rep = repmat(map, npoints, 1);


  %find the error vector energy relative to closest constellation point
  diff = points_rep - map_rep; 	
  diff_power = abs(diff).^2;	
  [noise_power_vector, colidx] = min(diff_power, [], 2);	
  rowidx = 1:size(diff_power,1);
  rowidx = rowidx.';
  ind = sub2ind(size(diff_power),rowidx,colidx);
  nearest_star = map_rep(ind);
  nearest_map_power = abs(nearest_star).^2;	%e(k) - error vector energy

  %normalize the error vector energy - v0
  %snr_vector = nearest_map_power./noise_power_vector;
  %snr_vector_dB = 10 * log10(snr_vector);
  %%[diff_power noise_power_vector nearest_star nearest_map_power snr_vector snr_vector_dB]
  %avgsnr = mean(snr_vector);
  %avgsnr_dB = 10 * log10(avgsnr);

  %normalize the error vector energy - v1
  %This version is implemented according to http://www.mathworks.com/help/comm/ref/evmmeasurement.html,
  %with EVM Normalization Method chosen as Reference Signal.
  snr_vector = nearest_map_power./noise_power_vector;	%questionable
  snr_vector_dB = 10 * log10(snr_vector);		%questionable
  mean_reference_symbol_energy = mean(nearest_map_power)
  mean_error_vector_energy = mean(noise_power_vector)
  evm_rms = sqrt(mean_error_vector_energy/mean_reference_symbol_energy)
  snr_from_evm_rms_dB = -20*log10(evm_rms)
  avgsnr = 1/(evm_rms^2);
  avgsnr_dB = snr_from_evm_rms_dB
end
