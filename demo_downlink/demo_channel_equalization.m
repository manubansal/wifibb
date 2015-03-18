function [stats, data, rx_data_syms] = demo_channel_equalization(samples, nsyms, chi, cmp, rxp, data, stats)

pilot_syms = wifi_generate_pilot_syms(cmp);
data.sig_and_data_tx_pilot_syms = [pilot_syms];

[stats data ofdm_syms_f] = wifi_ofdm_demod(samples, nsyms, data, rxp, stats);

[stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] ...
    = wifi_channel_correction(nsyms, rxp, data, stats, ofdm_syms_f, chi);

[stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] ...
    = wifi_pilot_phase_tracking(stats, data, rxp, ofdm_syms_f, uu_pilot_syms, nsyms);

[stats data rx_data_syms rx_pilot_syms uu_pilot_syms ofdm_syms_f] ...
    = wifi_pilot_sampling_delay_correction(stats, data, rxp, ofdm_syms_f, uu_pilot_syms, nsyms);

rx_data_syms = rx_data_syms(:,1:nsyms);