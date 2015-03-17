%% parameters
overall_snr = 25;
power_access = 1;
power_quickc = 0;

%% Generate the LTE access signal
cd(strcat(getenv('PARAMS_DIR'),'/wifi64'))

access_sim_params = default_sim_parameters();
access_tx_params = wifi_tx_parameters();
access_rx_params = wifi_rx_parameters();
access_common_params = wifi_common_parameters({});

access_msg = zeros(access_sim_params.msglen*8, 1);
access_rate = access_sim_params.rate;
access_cplen = access_common_params.cplen;

[samples_f, n_ofdm_syms, databits_i, databits_q, td_data_samples, td_pkt_samples, msg_scr] = wifi_tx_chain(...
    access_sim_params, access_tx_params, access_common_params, access_msg, access_rate, 'Access' , access_cplen);

access_samples = td_pkt_samples;

%% Generate the QuickC signal
cd(strcat(getenv('PARAMS_DIR'),'/wifi64'))

quickc_sim_params = default_sim_parameters();
quickc_tx_params = wifi_tx_parameters();
quickc_rx_params = wifi_rx_parameters();
quickc_common_params = wifi_common_parameters({});

quickc_msg = zeros(quickc_sim_params.msglen*8, 1);
quickc_rate = quickc_sim_params.rate;
quickc_cplen = quickc_common_params.cplen;

[samples_f, n_ofdm_syms, databits_i, databits_q, td_data_samples, td_pkt_samples, msg_scr] = wifi_tx_chain(...
    quickc_sim_params, quickc_tx_params, quickc_common_params, quickc_msg, quickc_rate, 'QuickC', quickc_cplen);

quickc_samples =  vertcat(zeros(length(td_pkt_samples) - length(td_data_samples), 1), td_data_samples);

%% Mix the two signals
combined_signal = sqrt(power_access)*access_samples + sqrt(power_quickc)*quickc_samples;

%% pass through channel
noisy_signal = wifi_awgn(combined_signal, overall_snr);
padded_signal = vertcat(zeros(1000, 1), noisy_signal, zeros(1000, 1));

%% Run the RX chain for access till the point of channel equalization of packet 1

%% Find correlation
data.samples = padded_signal.';
pilot_syms = wifi_generate_pilot_syms(access_common_params);
data.sig_and_data_tx_pilot_syms = [pilot_syms];
data.pkt_start_point = -1;
stats = util_rx_stats();

display('------------------- begin find_stream_correlation -------------------');
[stats data] = wifi_find_stream_correlation(data, access_rx_params, stats);
display('------------------- done find_stream_correlation -------------------');

%% Detect Packet
data.deinterleave_tables = wifi_deinterleaveTables(access_rx_params);

display('-------------- detecting packet --------------')
[stats data] = wifi_detect_next_packet(data, access_rx_params, stats);
if (data.pkt_start_point == -1)
    display('pkt_start_point is -1, breaking')
    break;
end
if (data.pkt_start_point == -Inf)
    display('pkt_start_point is -Inf, breaking')
    break;
end
display('------------------- done detecting packet -------------------');

%% CFO correction
[stats data pkt_samples] = wifi_get_packet(data, access_rx_params, stats);

[stats, pkt_samples, coarse_cfo_freq_off_khz] = ...
    wifi_coarse_cfo_correction(access_rx_params, stats, pkt_samples, data.corrvec, data.pkt_start_point);

[stats, pkt_samples, fine_cfo_freq_off_khz] = ...
    wifi_fine_cfo_correction(access_common_params, access_rx_params, stats, pkt_samples, access_common_params.cplen);

%% Channel Estimation
[stats, uu_ltf1, uu_ltf2, ltf1_f, ltf2_f, ltf_f_av, ch, ch_abs_db, chi] ...
    = wifi_preamble_channel_estimation(access_common_params, access_rx_params, stats, pkt_samples, access_common_params.cplen);

%% Process Packet Header

sig_samples = pkt_samples(access_common_params.stf_len + access_common_params.ltf_len + 1:access_common_params.stf_len + access_common_params.ltf_len + access_common_params.sig_len);
[ndbps_sig, rt120_sig, ncbps_sig, nbpsc_sig, nsubc_sig, psubc_idx_sig, d1subc_idx_sig, dsubc_idx_sig] = wifi_parameter_parser(access_rx_params, access_sim_params.rate_sig);
nbpsc = nbpsc_sig;	%signal field is coded with bpsk
nsyms = access_sim_params.sig_syms;	%signal field occupies one ofdm symbol
[ig1, ig2, ig3, ig4, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameter_parser(access_rx_params,0);

[stats data ofdm_syms_f] = wifi_ofdm_demod(sig_samples, nsyms, data, access_rx_params, stats);

[stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] ...
    = wifi_channel_correction(nsyms, access_rx_params, data, stats, ofdm_syms_f, chi);

[stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] ...
    = wifi_pilot_phase_tracking(stats, data, access_rx_params, ofdm_syms_f, uu_pilot_syms, nsyms);

[stats data rx_data_syms rx_pilot_syms uu_pilot_syms ofdm_syms_f] ...
    = wifi_pilot_sampling_delay_correction(stats, data, access_rx_params, ofdm_syms_f, uu_pilot_syms, nsyms);

[rx_data_bits]  		= wifi_wrapper_demap_packet(rx_data_syms, nsyms, nbpsc, access_rx_params.soft_slice_nbits);

[stats data rx_data_bits_deint]   = wifi_wrapper_deinterleave(data, access_rx_params, stats, rx_data_bits, nbpsc);


[rx_data_bits_dec]    = wifi_wrapper_decode(rx_data_bits_deint,ndbps_sig - 6 , access_rx_params);

[stats data]		= wifi_parse_signal_top(data, access_sim_params, access_common_params, access_rx_params, stats, rx_data_bits_dec);

%% validity of sig field

nbpsc = data.sig_modu;
nsyms = data.sig_nsyms;
coderate = data.sig_code;
data_samples = pkt_samples(access_common_params.stf_len + access_common_params.ltf_len + access_common_params.sig_len + 1: end);

not_enough_samples = false;
if (length(data_samples) < nsyms * access_rx_params.sym_len_s)
    not_enough_samples = true;
end


if (~(data.sig_valid && data.sig_parityCheck) || not_enough_samples)
    parsed_data = [];
    frame_type = -1;
    ber = -1;
    crcValid = -1;
    data.frame_type = frame_type;
    display('------------------------------------------------------------');
    display('parse data results: ');
    display(strcat('frame_type (0: data, 1: ack, 2: unknown):', num2str(frame_type), ...
        ' ber:', num2str(ber), ' crcValid:', num2str(crcValid)));
    display('------------------------------------------------------------');
        
    if (not_enough_samples)
        display('ERROR: not enough data samples in the trace, continuing without data decode...')
    else
        display('signal field not valid, continuing without data decode...')
    end
    
    return
end


%% Channel correction for rest of symbols

[stats data ofdm_syms_f]  		= wifi_ofdm_demod([sig_samples data_samples], nsyms+ 1, data, access_rx_params, stats);

[stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] = wifi_channel_correction(nsyms + 1, access_rx_params, data, stats, ofdm_syms_f, chi);
[stats data ofdm_syms_f rx_pilot_syms uu_pilot_syms] = wifi_pilot_phase_tracking(stats, data, access_rx_params, ofdm_syms_f, uu_pilot_syms, nsyms + 1);
[stats data rx_data_syms rx_pilot_syms uu_pilot_syms ofdm_syms_f] = ...
    wifi_pilot_sampling_delay_correction(stats, data, access_rx_params, ofdm_syms_f, uu_pilot_syms, nsyms + 1);

%% Throw away signal field
rx_data_syms(:,1)=[];
rx_data_syms = rx_data_syms(:,1:nsyms);

[rx_data_bits]  = wifi_wrapper_demap_packet(rx_data_syms, data.sig_nsyms, data.sig_modu, access_rx_params.soft_slice_nbits);

[stats data rx_data_bits_deint]  	= wifi_wrapper_deinterleave(data, access_rx_params, stats, rx_data_bits, nbpsc);
rx_data_bits_deint = reshape(rx_data_bits_deint, prod(size(rx_data_bits_deint)), 1);
[stats data rx_data_bits_depunct]     = wifi_wrapper_depuncture(data, access_rx_params, stats, rx_data_bits_deint, coderate);
%decode the actual data length portion
data_and_tail_length_bits = access_sim_params.service_bits + data.sig_payload_length * 8 + access_sim_params.tail_bits;	%first 16 for service, last 6 for tail
actual_data_portion_with_tail = rx_data_bits_depunct(1:(data_and_tail_length_bits * 2));	%since it's a half rate code

[rx_data_bits_dec]         = wifi_wrapper_decode(actual_data_portion_with_tail, access_sim_params.service_bits + data.sig_payload_length * 8, access_rx_params);

rx_data_bits_descr = wifi_descramble(rx_data_bits_dec);

%retain only upto the data portion, including service field but discarding tail and pad
rx_data_bits_descr = rx_data_bits_descr(1:(access_sim_params.service_bits + data.sig_payload_length * 8));
rx_data_bytes = reshape(rx_data_bits_descr, 8, data.sig_payload_length + (access_sim_params.service_bits/8));
size_rx_data_bytes = size(rx_data_bytes);

[parsed_data frame_type ber crcValid service_field da seq] = wifi_parse_payload(rx_data_bytes);
data.parsed_data = parsed_data;
data.frame_type = frame_type;
data.ber = ber;
data.crcValid = crcValid;
data.service_field = service_field;
data.da = da;
data.seq = seq;

display(strcat('CRC = ', num2str(crcValid)));




