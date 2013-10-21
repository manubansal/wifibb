
function util_plot_channel_estimates(ltf1_f, ltf2_f, ltf_f_av, ch, ch_abs_db)
  figure

  subplot(6,1,1)
  hold on
  plot(1:64, abs(ltf1_f),'g-.');
  plot(1:64, abs(ltf2_f),'b-.');
  plot(1:64, abs(ltf_f_av),'r-.');
  title('|.| of ltf symbols in frequency domain after cfo correction, red: mean')
  grid on
  %title('|.|')

  subplot(6,1,2)
  hold on
  plot(1:64, real(ltf1_f),'g-.');
  plot(1:64, real(ltf2_f),'b-.');
  plot(1:64, real(ltf_f_av),'r-.');
  title('real(.)')
  grid on

  subplot(6,1,3)
  hold on
  plot(1:64, imag(ltf1_f),'g-.');
  plot(1:64, imag(ltf2_f),'b-.');
  plot(1:64, imag(ltf_f_av),'r-.');
  title('imag(.)')
  grid on

  subplot(6,1,4)
  plot(1:64, abs(ch),'g-.');
  title('|.| of channel, linear');
  grid on

  subplot(6,1,4)
  plot(1:64, abs(ch),'g-.');
  title('|.| of channel, linear');
  grid on

  subplot(6,1,5)
  plot(1:64, ch_abs_db,'b-.');
  title('|.| of channel, dB');
  grid on

  subplot(6,1,6)
  plot(1:64, angle(ch),'b-.');
  title('angle(.) of channel');
  grid on
end
