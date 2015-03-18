%% Parameters for mixing the two signals
mixing_params.overall_snr = 30;
% 15 dB margin 
mixing_params.power_access = 0.9693;
mixing_params.power_quickc = 0.0307;

%% Generate Access Signal
[access_samples access_datasyms access_smp access_txp access_rxp access_cmp] = demo_generate_access_signal('/access1024');

%% Generate QuickC Signal
[quickc_samples quickc_datasyms quickc_smp quickc_txp quickc_rxp quickc_cmp] = demo_generate_quickc_signal('/quickc1024');

%% Mix the two signals
combined_signal = sqrt(mixing_params.power_access)*access_samples + sqrt(mixing_params.power_quickc)*quickc_samples;

%% pass through channel
noisy_signal = wifi_awgn(combined_signal, mixing_params.overall_snr);
padded_signal = vertcat(zeros(1000, 1), noisy_signal, zeros(1000, 1));

%% Find correlation of incoming signal 
display('------------------- finding stream correlation -------------------');
data.samples = padded_signal.';
[stats data] = wifi_find_stream_correlation(data, access_rxp);

%% Detect access packet start
display('-------------- detecting packet --------------');
data.pkt_start_point = -1;
[stats data] = wifi_detect_next_packet(data, access_rxp, stats);
if (data.pkt_start_point <= -1)
    error('Packet not found')
end

%% CFO correction of the signal
display('---------------- CFO correction -----------------');
[stats data pkt_samples] = demo_cfo_correct(stats, data, access_cmp, access_rxp);

%% Channel Estimation
[stats, uu_ltf1, uu_ltf2, ltf1_f, ltf2_f, ltf_f_av, ch, ch_abs_db, chi] ...
    = wifi_preamble_channel_estimation(access_cmp, access_rxp, stats, pkt_samples, access_cmp.cplen);

%% OFDM demod and channel equalization of the signal field
sig_samples = pkt_samples(access_cmp.stf_len + access_cmp.ltf_len + 1 : access_cmp.stf_len + access_cmp.ltf_len + access_cmp.sig_len);
[stats, data, rx_sig_syms] = demo_channel_equalization(sig_samples, access_smp.sig_syms, chi, access_cmp, access_rxp, data, stats);

%% Decode the sig field
[stats, data] = demo_sig_field_decoding(rx_sig_syms, access_smp, access_rxp, access_cmp, stats, data);

%% validity of sig field
data_samples = pkt_samples(access_cmp.stf_len + access_cmp.ltf_len + access_cmp.sig_len + 1: end);

not_enough_samples = false;
if (length(data_samples) < data.sig_nsyms * access_rxp.sym_len_s)
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
    display(strcat('Access : frame_type (0: data, 1: ack, 2: unknown):', num2str(frame_type), ...
        ' ber:', num2str(ber), ' crcValid:', num2str(crcValid)));
    display('------------------------------------------------------------');
        
    if (not_enough_samples)
        display('ERROR: not enough data samples in the trace, continuing without data decode...')
    else
        display('signal field not valid, continuing without data decode...')
    end
    
    return
end

%% OFDM demod and channel equalization of the rest of the symbol
rx_samples = [sig_samples data_samples];
rx_nsyms = access_smp.sig_syms + data.sig_nsyms;
[stats, data, rx_syms] = demo_channel_equalization(rx_samples, rx_nsyms, chi, access_cmp, access_rxp, data, stats);

%% Assume that the access layer is in QPSK for data and BPSK for signal field and guess the symbols

QPSK = [-1-1j,-1+1j, 1-1j, 1+1j]./sqrt(2);
BPSK = [-1, 1];

data_pos_real = real(rx_syms(:,2:end)) > 0;
data_pos_imag = imag(rx_syms(:,2:end)) > 0;

data_guesses = QPSK(1)*(~data_pos_real & ~data_pos_imag) + ...
QPSK(2)*(~data_pos_real & data_pos_imag) + ...
QPSK(3)*(data_pos_real & ~data_pos_imag) + ...
QPSK(4)*(data_pos_real & data_pos_imag) ;

sig_pos = real(rx_syms(:,1)) > 0;

sig_guesses = BPSK(1)*(~sig_pos) + BPSK(2)*sig_pos; 

total_guesses = horzcat(sig_guesses, data_guesses);

%% Calculate error rate of hard slicing
total_data_syms = numel(data_guesses);
erroneous_hard_sliced_syms = sum(sum(find(data_guesses - access_datasyms(:,2:end))));
display(['************Error rate of hard slicing = ',num2str(erroneous_hard_sliced_syms/total_data_syms)]);

%% cancel the symbols

leftover_syms = rx_syms - total_guesses;

%% re-scale the new constellation (quickc)

rx_quickc_syms = leftover_syms*sqrt(mixing_params.power_access)/sqrt(mixing_params.power_quickc);

%% Process Packet Header for quickc
[stats, data] = demo_sig_field_decoding(rx_quickc_syms(:,1), quickc_smp, quickc_rxp, quickc_cmp, stats, data);

%% validity of sig field for quickc
not_enough_samples = false;
if (size(rx_quickc_syms(:,2:end),2) < data.sig_nsyms)
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
    display(strcat('QuickC : frame_type (0: data, 1: ack, 2: unknown):', num2str(frame_type), ...
        ' ber:', num2str(ber), ' crcValid:', num2str(crcValid)));
    display('------------------------------------------------------------');
        
    if (not_enough_samples)
        display('ERROR: not enough data samples in the trace, continuing without data decode...')
    else
        display('signal field not valid, continuing without data decode...')
    end
    
    return
end

%% Decode quickc
data = demo_soft_slicing_decoding(rx_quickc_syms(:,2:end), quickc_smp, quickc_rxp, stats, data);
display(strcat('**********QuickC : CRC Valid = ', num2str(data.crcValid))); 

