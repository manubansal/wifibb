function [stats data pkt_samples] = demo_cfo_correct(stats, data, cmp, rxp)

[stats data pkt_samples] = wifi_get_packet(data, rxp, stats);

[stats, pkt_samples, coarse_cfo_freq_off_khz] = ...
    wifi_coarse_cfo_correction(rxp, stats, pkt_samples, data.corrvec, data.pkt_start_point);

[stats, pkt_samples, fine_cfo_freq_off_khz] = ...
    wifi_fine_cfo_correction(cmp, rxp, stats, pkt_samples, cmp.cplen);
end

