%------------------------------------------------------------------------------------
function [stats parsed_data frame_type crcValid rx_data_bits_dec rx_data_bytes] = ...
	wifi_rx_chain(...
		data, sim_params, copt, opt, stats, confStr, cplen...
		)
%------------------------------------------------------------------------------------
  [stats data pkt_samples] 			= wifi_get_packet(data, opt, stats);
  if length(pkt_samples) == 0
    parsed_data = [];
    frame_type = -1;
    crcValid = -1;
    rx_data_bits_dec = [];
    rx_data_bytes = [];
    display('could not get samples for this pkt, skipping...')
    return
  end

  display(['Got pkt at power-ratio estimated dB SNR = ' num2str(stats.snr_db(end))])
  power_ratio_SNR_dB = (stats.snr_db(end));

  [stats parsed_data frame_type crcValid rx_data_bits_dec rx_data_bytes] = ...
	wifi_rx_chain_after_pkt_detection(...
		data, sim_params, copt, opt, stats, confStr, cplen, pkt_samples...
		);
end
