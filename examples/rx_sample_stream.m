function [rx_pkts, pkt_start_points] = rx_sample_stream(samples)

CURR_DIR = pwd;
cd(strcat(getenv('PARAMS_DIR'), '/wifi64'));
sim_params = default_sim_parameters();
rx_params = wifi_rx_parameters();
common_params = wifi_common_parameters({});
cd(CURR_DIR);
tag = sim_params.tag;
cplen = common_params.cplen;

[rx_pkts, pkt_start_points] = wifi_rx_pkt_train(sim_params, ...
    common_params, rx_params, samples, tag, cplen);

crc_vec = zeros(1, length(rx_pkts));
for idx = 1:length(rx_pkts)
    crc_vec(idx) = rx_pkts{idx}{3};
end
display(['Packets received :', num2str(length(rx_pkts))])
display(['CRC valid :', num2str(length(find(crc_vec == 1)))])