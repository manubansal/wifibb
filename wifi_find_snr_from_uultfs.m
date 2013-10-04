

%----------------------------------------------------------------------------------------------------------------------------
function [avg_snr snr_v] = wifi_find_snr_from_uultfs(uu_ltf1_m, uu_ltf2_m, ch_m)
%----------------------------------------------------------------------------------------------------------------------------

  ltf_sync_freq_domain = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0, ...
			  1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1]';
  ltf_sync_freq_domain = [ zeros(6,1); ltf_sync_freq_domain; zeros(5,1)];

  %Channel will vary in phase everytime, so channel complex values are not consistent, leading to large std
  %ch_avg = mean(ch_m, 2);
  %ch_std_real = std(real(ch_m), 0, 2);
  %ch_std_imag = std(imag(ch_m), 0, 2);
  %[ch_avg abs(ch_avg) ch_std_real ch_std_imag]

  %Channel magnitudes have low variance since the channel is static in time, as expected
  %So we can work with our scheme of averaging snr across all packets, since channel is not varying in time
  chm_m = abs(ch_m);
  chm_avg = mean(chm_m, 2);
  chm_std = std(chm_m, 0, 2);
  %[chm_avg chm_std]
  chm_avg_nz = chm_avg(find(chm_avg > 0));
  min_chm_avg = min(chm_avg_nz)
  max_chm_std = max(chm_std)

  chm_avg_sq = chm_avg .* chm_avg;

  chm_sq_m = chm_m .* chm_m;
  chm_sq_avg = mean(chm_sq_m, 2);

  noise_m_1 = uu_ltf1_m - ch_m;
  noise_m_2 = uu_ltf2_m - ch_m;
  noise_m = [noise_m_1 noise_m_2];
  noise_avg = mean(noise_m, 2);

  %format long
  %display('a noise vector and average noise over a lot of samples:');
  %[noise_m_1(:,1) noise_avg]
  %pause
  %format

  %algo 1
  %%noise_var_r = (std(real(noise_m), 0, 2));
  %%noise_var_i = (std(imag(noise_m), 0, 2));
  %%noise_var_r = noise_var_r.*noise_var_r;
  %%noise_var_i = noise_var_i.*noise_var_i;
  %%display('noise_var_i and noise_var_q:');
  %%[noise_var_r noise_var_i]
  %%%noise_var = (noise_var_r + noise_var_i)/2;	%sigma^2/2
  %%cplx_noise_var = noise_var_r + noise_var_i;	%sigma^2
  %%%snr_lin = chm_avg_sq./noise_var;
  %%snr_lin = chm_sq_avg./cplx_noise_var;
  %%snr_db = 10*log10(snr_lin)
  %%pause

  %algo 2
  noise_power_avg = mean(noise_m .* conj(noise_m), 2);
  snr_lin = chm_sq_avg./noise_power_avg;
  snr_db = 10*log10(snr_lin);

  avg_snr = 10*log10(mean(chm_sq_avg)/mean(noise_power_avg));
  snr_v = snr_db;


end
