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
      map = QAM16;
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

  diff = points_rep - map_rep;
  diff_power = abs(diff);
  [noise_power_vector, colidx] = min(diff_power, [], 2);
  rowidx = 1:size(diff_power,1);
  rowidx = rowidx.';
  ind = sub2ind(size(diff_power),rowidx,colidx);
  nearest_star = map_rep(ind);
  nearest_map_power = abs(nearest_star);
  snr_vector = nearest_map_power./noise_power_vector;
  snr_vector_dB = 10 * log10(snr_vector);
  %[diff_power noise_power_vector nearest_star nearest_map_power snr_vector snr_vector_dB]

  avgsnr = mean(snr_vector);
  avgsnr_dB = 10 * log10(avgsnr);
end
