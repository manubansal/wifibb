
function [stats data] = util_generate_constellation_plots(stats, data, opt, uu_pilot_syms)
  if (opt.GENERATE_PER_PACKET_PLOTS)
    figure
    subplot(3,1,1)
    hold on
    plot(abs(uu_pilot_syms(1,:)),'r.-')
    plot(abs(uu_pilot_syms(2,:)),'g.-')
    plot(abs(uu_pilot_syms(3,:)),'b.-')
    plot(abs(uu_pilot_syms(4,:)),'k.-')
    title('pilot tone 1-4, rgbk, |.|')

    subplot(3,1,2)
    hold on
    plot(10*log10(abs(uu_pilot_syms(1,:))),'r.-')
    plot(10*log10(abs(uu_pilot_syms(2,:))),'g.-')
    plot(10*log10(abs(uu_pilot_syms(3,:))),'b.-')
    plot(10*log10(abs(uu_pilot_syms(4,:))),'k.-')
    title('pilot tone 1-4, rgbk, |.| dB')

    subplot(3,1,3)
    hold on
    plot(angle(uu_pilot_syms(1,:)),'r.-')
    plot(angle(uu_pilot_syms(2,:)),'g.-')
    plot(angle(uu_pilot_syms(3,:)),'b.-')
    plot(angle(uu_pilot_syms(4,:)),'k.-')
    title('pilot tone 1-4, rgbk angle(.)')

    %subplot(4,1,3)
    %plot(abs(uu_pilot_syms(2,:)))
    %title('pilot tone 2, |.|')

    %subplot(4,1,4)
    %plot(angle(uu_pilot_syms(2,:)))
    %title('pilot tone 2, angle(.)')
  end

  %pause

  %display('first three ofdm symbols in frequency domain (each col is a symbol):');
  %ofdm_syms_f(:,1:3)

end
