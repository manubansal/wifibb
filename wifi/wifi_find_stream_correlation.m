
%----------------------------------------------------------------------------------------------------------------------------
function [stats data]= wifi_find_stream_correlation(data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
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


  %figure
  %plot(abs(corrvec))
  x = 1:length(abs(samples));

  if (opt.GENERATE_ONE_TIME_PLOTS)
    figure
    %plotyy(x, abs(samples), x, abscorrvec);
    title('Sample magnitudes and correlation magnitudes');
    plotyy(x, 10*log10(abs(samples)), x, abscorrvec);
    grid on

    figure
    %plotyy(x, abs(samples), x, abscorrvec);
    title('Sample magnitudes and correlation magnitude squares');
    plotyy(x, 10*log10(abs(samples)), x, abscorrvecsq);
    grid on

    figure
    subplot(2,2,1);
    plot(x, abs(samples), 'o-');
    subplot(2,2,3);
    plot(x, abscorrvec, 'g.-');
    subplot(2,2,[2 4]);
    %plotyy(x, abs(samples), x, abscorrvec);
    plotyy(x, 10*log10(abs(samples)), x, abscorrvec);
    grid on

  end

  data.corrvec = corrvec;
  data.abscorrvec = abscorrvec;
  data.abscorrvecsq = abscorrvecsq;
end
