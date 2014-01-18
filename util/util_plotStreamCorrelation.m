function util_plotStreamCorrelation(samples, abscorrvec, abscorrvecsq, figure_handle, subplot_handles)
  if nargin < 5
    display('creating stream correlation figure handle')
    figure_handle = figure();
    subplot_handles = {};
    subplot_handles{1} = subplot(4,2,[1 2]);
    subplot_handles{2} = subplot(4,2,[3 4]);
    subplot_handles{3} = subplot(4,2,5);
    subplot_handles{4} = subplot(4,2,7);
    subplot_handles{5} = subplot(4,2,[6 8]);
  end

  figure(figure_handle)

  x = 1:length(abs(samples));

  subplot(subplot_handles{1})
  %plotyy(x, abs(samples), x, abscorrvec);
  title('Sample magnitudes and correlation magnitudes');
  plotyy(x, 10*log10(abs(samples)), x, abscorrvec);
  grid on

  subplot(subplot_handles{2})
  %plotyy(x, abs(samples), x, abscorrvec);
  title('Sample magnitudes and correlation magnitude squares');
  plotyy(x, 10*log10(abs(samples)), x, abscorrvecsq);
  grid on

  %subplot(2,2,1);
  subplot(subplot_handles{3})
  plot(x, abs(samples), 'o-');

  %subplot(2,2,3);
  subplot(subplot_handles{4})
  plot(x, abscorrvec, 'g.-');

  %subplot(2,2,[2 4]);
  subplot(subplot_handles{5})
  plotyy(x, 10*log10(abs(samples)), x, abscorrvec);
  grid on
end
