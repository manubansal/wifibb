function rx_packets = rx_sample_stream(samples)

CURR_DIR = pwd;
cd(strcat(getenv('PARAMS_DIR'), '/wifi64'));
sim_params = default_sim_parameters();
rx_params = wifi_rx_parameters();
common_params = wifi_common_parameters({});
cd(CURR_DIR);
tag = sim_params.tag;
cplen = common_params.cplen;

rx_packets = wifi_rx_pkt_train(sim_params, common_params, rx_params, ...
    samples, tag, cplen);