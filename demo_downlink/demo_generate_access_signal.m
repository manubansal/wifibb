function [access_samples access_datasyms access_smp access_txp access_rxp access_cmp] = demo_generate_access_signal(subdir_str)

cd(strcat(getenv('PARAMS_DIR'),subdir_str))

access_smp = default_sim_parameters();
access_txp = wifi_tx_parameters();
access_rxp = wifi_rx_parameters();
access_cmp = wifi_common_parameters({});
cd ../..

access_msg = zeros(access_smp.msglen*8, 1);
access_rate = access_smp.rate;
access_cplen = access_cmp.cplen;

[ig1, ig2, ig3, ig4, access_datasyms, td_data_samples, td_pkt_samples, ig5] = wifi_tx_chain(...
    access_smp, access_txp, access_cmp, access_msg, access_rate, 'Access' , access_cplen);

access_samples = td_pkt_samples;

end

