function [avgsnr avgsnr_dB snr_vector snr_vector_dB avgsnr_cross_dB] = util_ltfSNR(uu_ltf1, uu_ltf2, chi)
  %[uu_ltf1 uu_ltf2 chi]				%sign normalized
  normalized_ltf1 = uu_ltf1 .* chi;			%equalized
  normalized_ltf2 = uu_ltf2 .* chi;			%equalized
  normalized_ltf1_52 = [normalized_ltf1(7:32); normalized_ltf1(34:59)];
  normalized_ltf2_52 = [normalized_ltf2(7:32); normalized_ltf2(34:59)];
  normalized_ltfs = [normalized_ltf1_52; normalized_ltf2_52];
  ideal_normalized_ltfs = ones(52 * 2,1);	%since ideal ltfs are all magnitude 1 symbols
  noise_vector = normalized_ltfs - ideal_normalized_ltfs;
  noise_power_vector = abs(noise_vector).^2;

  snr_vector = 1./noise_power_vector;		%since ideal signal vector has power = 1
  snr_vector_dB = 10 * log10(snr_vector);
  avgsnr = mean(snr_vector);
  avgsnr_dB = 10 * log10(avgsnr);

  avgsnr_cross_dB = 0
  %ltf_snr_vector_dB = snr_vector_dB

  %avg_noise_power = mean(noise_power_vector);
  %ltf_snr_2 = 10*log10(1/avg_noise_power)
end
