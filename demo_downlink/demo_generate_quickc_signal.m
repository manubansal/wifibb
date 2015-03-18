function [quickc_samples quickc_datasyms quickc_smp quickc_txp quickc_rxp quickc_cmp] = demo_generate_quickc_signal(subdir_str)

cd(strcat(getenv('PARAMS_DIR'),subdir_str))

quickc_smp = default_sim_parameters();
quickc_txp = wifi_tx_parameters();
quickc_rxp = wifi_rx_parameters();
quickc_cmp = wifi_common_parameters({});
cd ../..

quickc_msg = zeros(quickc_smp.msglen*8, 1);
quickc_rate = quickc_smp.rate;
quickc_cplen = quickc_cmp.cplen;

[ig1, ig2, ig3, ig4, quickc_datasyms, td_data_samples, td_pkt_samples, ig5] = wifi_tx_chain(...
    quickc_smp, quickc_txp, quickc_cmp, quickc_msg, quickc_rate, 'quickc' , quickc_cplen);

quickc_samples = vertcat(zeros(length(td_pkt_samples) - length(td_data_samples), 1), td_data_samples);
end
