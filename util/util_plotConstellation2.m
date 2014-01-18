
function [stats data] = util_plotConstellation2(stats, data, uu_pilot_syms, figure_handle, subplot_handles)
  if nargin < 5
    display('creating constellation figure handle')
    pause
    figure_handle = figure()
    subplot_handles = {}
    for ii = 1:3
      subplot_handles{ii} = subplot(3,1,ii)
    end
  end

  figure(figure_handle);

  %subplot(3,1,1)
  subplot(subplot_handles{1})
  plot(abs(uu_pilot_syms(1,:)),'r.-')
  hold on
  plot(abs(uu_pilot_syms(2,:)),'g.-')
  plot(abs(uu_pilot_syms(3,:)),'b.-')
  plot(abs(uu_pilot_syms(4,:)),'k.-')
  hold off
  title('pilot tone 1-4, rgbk, |.|')

  %subplot(3,1,2)
  subplot(subplot_handles{2})
  plot(10*log10(abs(uu_pilot_syms(1,:))),'r.-')
  hold on
  plot(10*log10(abs(uu_pilot_syms(2,:))),'g.-')
  plot(10*log10(abs(uu_pilot_syms(3,:))),'b.-')
  plot(10*log10(abs(uu_pilot_syms(4,:))),'k.-')
  hold off
  title('pilot tone 1-4, rgbk, |.| dB')

  %subplot(3,1,3)
  subplot(subplot_handles{3})
  plot(angle(uu_pilot_syms(1,:)),'r.-')
  hold on
  plot(angle(uu_pilot_syms(2,:)),'g.-')
  plot(angle(uu_pilot_syms(3,:)),'b.-')
  plot(angle(uu_pilot_syms(4,:)),'k.-')
  hold off
  title('pilot tone 1-4, rgbk angle(.)')

  %subplot(4,1,3)
  %plot(abs(uu_pilot_syms(2,:)))
  %title('pilot tone 2, |.|')

  %subplot(4,1,4)
  %plot(angle(uu_pilot_syms(2,:)))
  %title('pilot tone 2, angle(.)')

  %pause

  %display('first three ofdm symbols in frequency domain (each col is a symbol):');
  %ofdm_syms_f(:,1:3)

end
