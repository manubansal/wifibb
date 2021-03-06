
%----------------------------------------------------------------------------------------------------------------------------
function [stats data]= wifi_find_stream_correlation(data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  if nargin < 3
      stats = util_rx_stats();
  end
  
  %plotSamples(samples);
  samples = data.samples;
  corrwin = opt.corrwin;
  %corr_threshold = opt.corr_threshold;

  %stats.avg_stream_power = mean(abs(samples).^2);
  %stats.avg_stream_power_2 = power(samples);

  [corrvec abscorrvec abscorrvecsq norm1val norm2val normval norm1terms norm2terms] = wifi_streamCorrelation(samples, corrwin); 
  isMetricHigh = (abscorrvecsq >= opt.sq_corr_threshold);
  %toc
  %pause
  if (opt.writeVars_corr)
  writeVars_corr(corrvec, abscorrvec, abscorrvecsq, norm1val, norm2val, normval, corrwin, norm1terms, norm2terms, isMetricHigh);
  end
  %pause

  if (opt.printVars_corr)
	  format long e
	  ns = 6000;
	  i = [1:ns] + 160;
	  %c = corrvec(1:ns);
	  %c = abscorrvecsq(1:ns).*abscorrvecsq(1:ns);
	  c = abscorrvecsq(1:ns);
	  ci = [i; c]';
	  nbufs = ns/80;
	  for bufi=1:nbufs
		  corrvals = ci(((bufi-1)*80 + 1):(bufi*80),:)
		  pause
	  end
	  format short
  end

  data.corrvec = corrvec;
  data.abscorrvec = abscorrvec;
  data.abscorrvecsq = abscorrvecsq;
end
