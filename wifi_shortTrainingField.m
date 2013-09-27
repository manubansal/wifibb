
function [stf_time_domain, stf_time_domain_16bit] = wifi_shortTrainingField()
  short_sync_freq_domain = zeros(64,1);

  index_offset = 33;
  %NOTE: SQRT(13/6) IS 1.472
  short_sync_freq_domain(-24 + index_offset) = 1.472 + 1.472*j;
  short_sync_freq_domain(-20 + index_offset) = -1.472 - 1.472*j; 
  short_sync_freq_domain(-16 + index_offset) = 1.472 + 1.472*i 
  short_sync_freq_domain(-12 + index_offset) = -1.472 - 1.472*i 
  short_sync_freq_domain(-8 + index_offset)  = -1.472 - 1.472*i 
  short_sync_freq_domain(-4 + index_offset)  = 1.472 + 1.472*i 
  short_sync_freq_domain(4 + index_offset)   = -1.472 - 1.472*i
  short_sync_freq_domain(8 + index_offset)   = -1.472 - 1.472*i
  short_sync_freq_domain(12 + index_offset)  = 1.472 + 1.472*i
  short_sync_freq_domain(16 + index_offset)  = 1.472 + 1.472*i
  short_sync_freq_domain(20 + index_offset)  = 1.472 + 1.472*i
  short_sync_freq_domain(24 + index_offset)  = 1.472 + 1.472*i



  short_sync_time_oneperiod = ifft(ifftshift(short_sync_freq_domain));

  %s = short_sync_time_oneperiod

  TOTAL_SAMPLES = 161;

  %REPEAT 3 TIMES, FOR A TOTAL OF 192 SAMPLES, AND DELETE THE LAST 31
  stf_time_domain = repmat(short_sync_time_oneperiod,3,1);
  window_func = [0.5 ones(1,159) 0.5]';
  stf_sync_total = window_func.*[ stf_time_domain(1:161,1)];

  %Here is the complete short sync OFDM symbol, with ones padding the end:
  stf_time_domain = [window_func.*stf_time_domain(1:161,1);
			     0.2*ones(161,1)];
  stf_time_domain_16bit = round(3*stf_time_domain*32767/1.0);
end
