
%----------------------------------------------------------------------------------------------------------------------------
function [stats data]= wifi_detect_next_packet(data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  pkt_start_point = -1;
  abscorrvec = data.abscorrvec;
  abscorrvecsq = data.abscorrvecsq;

  %samples = data.samples;
  %corrwin = opt.corrwin;
  corr_threshold = opt.corr_threshold;
  sq_corr_threshold = opt.sq_corr_threshold;
  peak_search_win_size = opt.peak_search_win_size;

  %rxgain = opt.rxgain;
  %nsyms = opt.nsyms_data;
  %scale = opt.scale;
  %rxgain = opt.rxgain;
  %atten = opt.atten;
  %corr_threshold = opt.corr_threshold;
  %pkt_period_samples = opt.pkt_period_samples;
  %pkt_length_samples = opt.pkt_length_samples;
  %ns_to_skip = opt.ns_to_skip;
  %ns_to_process = opt.ns_to_process;

  %next_search_window_start = find(abscorrvec >= corr_threshold, 1);

  %%%version 1: pkt length is known, so that pkt length can be skipped while locating the next corr peak
  %%%next_search_window_start = find(abscorrvec(data.pkt_start_point+opt.pkt_length_samples+1:end) >= corr_threshold, 1) + ...
  %%%		data.pkt_start_point+opt.pkt_length_samples;

  %%%version 2: pkt length is not assumed
  %%%next_search_window_start = find(abscorrvec(data.pkt_start_point+opt.peak_search_win_size+1:end) >= corr_threshold, 1) + ...
  %%%		data.pkt_start_point+opt.peak_search_win_size;


  %%%version 3: same as version 2 except on squared correlation values
  next_search_window_start = find(abscorrvecsq(data.pkt_start_point+opt.peak_search_win_size+1:end) >= sq_corr_threshold, 1) + ...
  		data.pkt_start_point+opt.peak_search_win_size;

  next_search_window_i = next_search_window_start:next_search_window_start+peak_search_win_size-1;
  next_search_window_c = abscorrvec(next_search_window_start:min(end,next_search_window_start+peak_search_win_size-1));
  [m i] = max(next_search_window_c);
  pkt_start_point = next_search_window_i(i);

  if (length(pkt_start_point) == 0)
    display('no more packets detected');
    pkt_start_point = -Inf;
    m = -1;
    i = -1;
  else
    display(['maximum correlation value at any pkt start point:' num2str(m)]);
    %max_corr_val = m
    stats.min_max_corr_val = min(stats.min_max_corr_val, m);
    stats.max_max_corr_val = max(stats.max_max_corr_val, m);

    %%%version 2
    %%%if (m < corr_threshold)

    %%%version 3
    if (m < sq_corr_threshold)
      %m
      %i
      error('max_corr_less_than_corr_threshold','packet detect point has correlation value smaller than threshold');
    end
  end

  stats.max_corr_val = m;
  display('biasing pkt_start_point by shifting it back by configured number of shift-back samples...');
  pkt_start_point_old = pkt_start_point;
  pkt_start_point = pkt_start_point - opt.pkt_start_pnt_shift_back_bias_s;
  display(['pkt_start_point: ' num2str(pkt_start_point)]);
  stats.pkt_start_points(end+1,:) = pkt_start_point;
  data.pkt_start_point = pkt_start_point;

  %display('pkt start points:');
  %pkt_start_points = stats.pkt_start_points
  %pause
end
