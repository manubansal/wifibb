
function util_plot_channel_estimates(ltf1_f, ltf2_f, ltf_f_av, ch, ch_abs_db, uu_ltf1, uu_ltf2, ...
	figure_handle, subplot_handles)
  if nargin < 9
    display('creating channel figure handle')
    pause
    figure_handle = figure()
    subplot_handles = {}
    for ii = 1:7
      subplot_handles{ii} = subplot(6,1,ii)
    end
  end

  figure(figure_handle);

  %subplot(6,1,1)
  subplot(subplot_handles{1})
  plot(1:64, abs(ltf1_f),'g-.');
  hold on
  plot(1:64, abs(ltf2_f),'b-.');
  plot(1:64, abs(ltf_f_av),'r-.');
  title('|.| of ltf symbols in frequency domain after cfo correction, red: mean')
  hold off
  grid on
  %title('|.|')

  %subplot(6,1,2)
  subplot(subplot_handles{2})
  plot(1:64, real(ltf1_f),'g-.');
  hold on
  plot(1:64, real(ltf2_f),'b-.');
  plot(1:64, real(ltf_f_av),'r-.');
  title('real(.)')
  hold off
  grid on

  %subplot(6,1,3)
  subplot(subplot_handles{3})
  plot(1:64, imag(ltf1_f),'g-.');
  hold on
  plot(1:64, imag(ltf2_f),'b-.');
  plot(1:64, imag(ltf_f_av),'r-.');
  title('imag(.)')
  hold off
  grid on

  %subplot(6,1,4)
  subplot(subplot_handles{4})
  plot(1:64, abs(ch),'g-.');
  title('|.| of channel, linear');
  grid on

  %subplot(6,1,4)
  subplot(subplot_handles{4})
  plot(1:64, abs(ch),'g-.');
  title('|.| of channel, linear');
  grid on

  %subplot(6,1,5)
  subplot(subplot_handles{5})
  plot(1:64, ch_abs_db,'b-.');
  title('|.| of channel, dB');
  grid on

  %subplot(6,1,6)
  subplot(subplot_handles{6})
  plot(1:64, angle(ch),'b-.');
  title('angle(.) of channel');
  grid on

  subplot(subplot_handles{7})
  plot(1:64, angle(uu_ltf1),'b-.');
  hold on
  plot(1:64, angle(uu_ltf2),'r-.');
  title('uu\_ltf1 (b) and uu\_ltf2 (r)')
  hold off
  grid on

end
