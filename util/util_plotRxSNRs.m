function util_plotRxSNRs(snr_v_data, snr_v_ack)
    figure
    plot(1:length(snr_v_data), snr_v_data, 'b')
    hold on
    plot(1:length(snr_v_ack), snr_v_ack, 'r')
    ylim([0 50]);
    grid on
    title('avg snr of data (b) and ack (r) pkts (dB), dc in the middle');
end
