
function [stf_time_domain, stf_time_domain_16bit, stf_sync_total] = wifi_shortTrainingField(cmp)
  %common_params = wifi_common_parameters({});
  common_params = cmp;

  short_sync_freq_domain = common_params.short_sync_freq_domain;


  short_sync_time_oneperiod = sqrt(length(short_sync_freq_domain))*ifft(ifftshift(short_sync_freq_domain));

  %s = short_sync_time_oneperiod

  TOTAL_SAMPLES = common_params.stf_len + 1;

  %REPEAT 3 TIMES, FOR A TOTAL OF 192 SAMPLES, AND DELETE THE LAST 31
  stf_time_domain = repmat(short_sync_time_oneperiod,3,1);
  window_func = [0.5 ones(1,TOTAL_SAMPLES - 2) 0.5]';
  stf_sync_total = window_func.*[ stf_time_domain(1:TOTAL_SAMPLES,1)];

  %Here is the complete short sync OFDM symbol, with ones padding the end:
  stf_time_domain = [window_func.*stf_time_domain(1:TOTAL_SAMPLES,1);
			     0.2*ones(TOTAL_SAMPLES,1)];
  stf_time_domain_16bit = round(3*stf_time_domain*32767/1.0);
end
