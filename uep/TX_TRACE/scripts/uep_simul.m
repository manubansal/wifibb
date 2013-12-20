
%% Settings
for rate = [36 54]
    
    switch rate
        case 54
            snr_val = 12:28;
        case 36
            snr_val = 10:16;
    end
    
    nTrials = 2;
    nSNR = length(snr_val);
    
    nBytes_payload = 96;
    nPayloads = 500;
    
    random_payload = 0; % Wish to send random data? Or data from video?
    
    % Constants
    IMAX = 256;
    nb_bin_conv = 8;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% WiFi parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rate_v = [6, 9, 12, 18, 24, 36, 48, 54];
    nbits = 6;	%soft-bit scale     %8
    tblen = 36; %tblen = 72;
    scale = 2^nbits - 1;
    ndbps_v = [24, 36, 48, 72, 96, 144, 192, 216];
    ncbps_v = [48, 48, 96, 96, 192, 192, 288, 288];
    nbpsc_v = [1, 1, 2, 2, 4, 4, 6, 6];
    rt120_v = [60, 90, 60, 90, 60, 90, 80, 90];
    
    
    ri = find(rate_v == rate);
    ndbps = ndbps_v(ri);
    ncbps = ncbps_v(ri);
    nbpsc = nbpsc_v(ri);
    rt120 = rt120_v(ri);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Payload preparation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % I:P ratio
    switch nbpsc
        case 1
            error('Cannot do UEP for 1 bit per subcarrier. ');
        case 2
            P_to_I_v = 1;
        case 4
            P_to_I_v = [1 3];
        case 6
            P_to_I_v = [1 2 5];
            %         P_to_I = 2;
            %         P_to_I = 1;
    end
    for P_to_I = P_to_I_v
        
        nI_elpp = nBytes_payload / (P_to_I + 1);
        nP_elpp = nBytes_payload - nI_elpp;
        assert(P_to_I*nI_elpp == nP_elpp, 'I:P ratio violated.');
        
        nI_totalbytes = nPayloads*round(nI_elpp);
        nP_totalbytes = nPayloads*nBytes_payload - nI_totalbytes;
        assert(P_to_I*nI_totalbytes == nP_totalbytes, 'I:P ratio violated.');
        
        
        switch random_payload
            case 0
                load('uep_payloads.mat');
                I_tx_stream = I_data(1:nI_totalbytes);
                P_tx_stream = P_data(1:nP_totalbytes);
            case 1
                I_tx_stream = randi(IMAX, nI_totalbytes, 1) - 1;
                P_tx_stream = randi(IMAX, nP_totalbytes, 1) - 1;
        end
        
        
        % UEP
        UEP_SAMPLES = cell(1, nPayloads);
        UEP_BASE_MSG = cell(1, nPayloads);
        UEP_VAL = cell(1, nPayloads);
        
        %% UEP TX
        for iter = 1:nPayloads
            %             iter = 1;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% pick the message
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %% Pick out chunk
            
            I_msg_e = I_tx_stream((iter-1)*nI_elpp + 1 : iter*nI_elpp);
            P_msg_e = P_tx_stream((iter-1)*nP_elpp + 1 : iter*nP_elpp);
            
            I_gop_index = (iter-1)*nI_elpp + 1;
            P_gop_index = (iter-1)*nP_elpp + 1;
            
            %% Convert to binary
            I_msg = dec2bin(I_msg_e, nb_bin_conv);
            I_msg = I_msg';
            I_msg = reshape(I_msg, [], 1);
            I_msg = str2num(I_msg);
            I_base_msg = I_msg;
            I_base_msg_len_bits = length(I_base_msg);
            
            P_msg = dec2bin(P_msg_e, nb_bin_conv);
            P_msg = P_msg';
            P_msg = reshape(P_msg, [], 1);
            P_msg = str2num(P_msg);
            P_base_msg = P_msg;
            P_base_msg_len_bits = length(P_base_msg);
            
            %         I_rx_data_field = I_msg;
            %         P_rx_data_field = P_msg;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% prepare the message with service, tail and pad bits
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            service = zeros(16,1);
            tail = zeros(6,1);
            I_msg_st = [service; I_msg; tail];
            P_msg_st = [service; P_msg; tail];
            
            npad = ceil(length([I_msg_st; P_msg_st])/ndbps) * ndbps - length([I_msg_st; P_msg_st]);
            
            % ensure the padding leads to a length divisible by 6 - for convenc
            npad_I = ceil(I_frac_gop*npad);
            while(mod(npad_I + length(I_msg_st), 6) ~= 0)
                npad_I = npad_I + 1;
            end
            npad_P = npad - npad_I;
            assert(npad_P >= 0, 'P padding negative!')
            
            I_msg_stp = [I_msg_st; zeros(npad_I, 1)];
            P_msg_stp = [P_msg_st; zeros(npad_P, 1)];
            
            n_ofdm_syms = length([I_msg_stp; P_msg_stp])/ndbps;
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% scramble the message
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            src_initstate = [1 0 1 1 1 0 1];
            [I_msg_scr I_scr_seq] = wifi_scramble(I_msg_stp, src_initstate);
            [P_msg_scr P_scr_seq] = wifi_scramble(P_msg_stp, src_initstate);
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% zero-out tail portion after scrambling
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            I_msg_scr(16 + I_base_msg_len_bits + 1:16 + I_base_msg_len_bits + 6) = 0;
            P_msg_scr(16 + P_base_msg_len_bits + 1:16 + P_base_msg_len_bits + 6) = 0;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% code and puncture
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            I_msg_code = wifi_cenc(I_msg_scr, rt120);
            P_msg_code = wifi_cenc(P_msg_scr, rt120);
            %coded_message_soft_bits = coded_message * scale;
            
            assert(length([I_msg_code; P_msg_code]) == ncbps*n_ofdm_syms);
            total_coded_bits = ncbps*n_ofdm_syms;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% offset
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Sample input
            % I_msg_code = [1:240]'; P_msg_code = 1000 + [1:912]';
            
            
            total_sc = total_coded_bits / nbpsc;
            nsc_ps = total_sc / n_ofdm_syms;    % number of subc per ofdm sym
            
            nI_bpsc = ceil( length(I_msg_code) / total_sc );
            
            offset = nI_bpsc * total_sc - length(I_msg_code);
            assert(offset >= 0, 'Offset is negative.');
            
            % pseudo indicates presence of other stuff
            I_pseudo_code_vector = [I_msg_code; P_msg_code(1:offset)];
            P_pseudo_code_vector = P_msg_code(offset + 1:end);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% arrange coded bits as ofdm symbols
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This ensures that interleaving occurs across a single ofdm symbol
            % I_pseudo_code_vector = [1:48*6]'; P_pseudo_code_vector = 1000 + [1:48*3*6]';
            
            nI_cbps = nI_bpsc * nsc_ps;     % these will include some from P
            nP_cbps = ncbps - nI_cbps;
            
            I_pseudo_code_syms_array = reshape(I_pseudo_code_vector, nI_cbps, n_ofdm_syms);
            P_pseudo_code_syms_array = reshape(P_pseudo_code_vector, nP_cbps, n_ofdm_syms);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% interleave
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Note: Since regular interleaving fails for nP_cbps = 3,
            % ----- we use our own interleaving technique.
            %             I_pseudo_code_syms_array_trial = reshape(1:48*6, 48,6);
            %             P_pseudo_code_syms_array_trial = reshape(-[1:144*6], 144,6);
            %             uep_msg_int_syms_trial = vidwifi_interleave(I_pseudo_code_syms_array_trial, P_pseudo_code_syms_array_trial);
            
            uep_msg_int_syms = vidwifi_interleave(I_pseudo_code_syms_array, P_pseudo_code_syms_array);
            %         [I_pseudo_deint_syms_array, P_pseudo_deint_syms_array] = vidwifi_deinterleave(uep_msg_int_syms, nbpsc, nI_cbps);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% map bits onto constellation symbols
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            uep_mapped_syms = [];
            for i = 1:n_ofdm_syms
                uep_mapped_syms = [uep_mapped_syms wifi_map(uep_msg_int_syms(:,i), nbpsc)];
            end
            uep_samples_f = reshape(uep_mapped_syms, numel(uep_mapped_syms), 1);
            
            UEP_SAMPLES{iter} = uep_samples_f;
            UEP_BASE_MSG{iter} = struct('I_base_msg'         , I_base_msg, ...
                'P_base_msg'         , P_base_msg);
            UEP_VAL{iter} = struct('offset'             , offset,...
                'nsc_ps'             , nsc_ps,...
                'ncbps'              , ncbps,...
                'nI_cbps'            , nI_cbps, ...
                'nbpsc'              , nbpsc,...
                'nI_bpsc'            , nI_bpsc,...
                'n_odfm_syms'        , n_ofdm_syms,...
                'I_base_msg_len_bits', I_base_msg_len_bits, ...
                'P_base_msg_len_bits', P_base_msg_len_bits);
            
        end
        
        
        %% Save to file
        UEP_STREAM = struct('I_tx_stream', I_tx_stream, 'P_tx_stream', P_tx_stream);
        save(strcat('uep_tx_', num2str(rate), '_', num2str(P_to_I)), 'UEP_SAMPLES', 'UEP_BASE_MSG', 'UEP_VAL', 'UEP_STREAM')
        
        
        %==== UEP: CHANNEL + RX CHAIN
        switch no_noise
            case 0
                %snr = 30; % 18, 5
            case 1
                snr = Inf;
        end
        
        UEP_BIT_ERRORS = containers.Map('KeyType', 'double', 'ValueType', 'any');
        
        for snr = snr_val
            I_bit_errors = 0; P_bit_errors = 0;
            I_length = 0; P_length = 0;
            
            for trial = 1:nTrials
                I_rx_stream = [];
                P_rx_stream = [];
                nPayloads = length(UEP_SAMPLES);
                
                
                for iter = 1:nPayloads
                    
                    % transmitted symbols
                    uep_samples_f = UEP_SAMPLES{iter};
                    I_base_msg = UEP_BASE_MSG{iter}.I_base_msg;
                    P_base_msg = UEP_BASE_MSG{iter}.P_base_msg;
                    
                    % parameters
                    offset = UEP_VAL{iter}.offset;
                    nsc_ps = UEP_VAL{iter}.nsc_ps;
                    ncbps = UEP_VAL{iter}.ncbps;
                    nI_cbps = UEP_VAL{iter}.nI_cbps;
                    nbpsc = UEP_VAL{iter}.nbpsc;
                    nI_bpsc = UEP_VAL{iter}.nI_bpsc;
                    n_odfm_syms = UEP_VAL{iter}.n_odfm_syms;
                    I_base_msg_len_bits = UEP_VAL{iter}.I_base_msg_len_bits;
                    P_base_msg_len_bits = UEP_VAL{iter}.P_base_msg_len_bits;
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% let's add some AWGN noise
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    switch no_noise
                        case 0
                            rx_uep_samples_f = awgn(uep_samples_f, snr, 'measured');
                        case 1
                            rx_uep_samples_f = uep_samples_f;
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% demap symbols
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %function softbits = wifi_softSlice(points, nbpsc, nbits, range)
                    rx_syms = reshape(rx_uep_samples_f, length(rx_uep_samples_f)/n_ofdm_syms, n_ofdm_syms);
                    rx_syms_softbits = [];
                    for i = 1:n_ofdm_syms
                        rx_syms_softbits = [rx_syms_softbits wifi_softSlice(rx_syms(:,i), nbpsc, nbits)];
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% deinterleave
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    [I_pseudo_deint_syms_array, P_pseudo_deint_syms_array] = ...
                        vidwifi_deinterleave(rx_syms_softbits , nbpsc, nI_cbps);
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% convert array of ofdm symbols to a vector of coded softbits
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    I_pseudo_deint_vector = I_pseudo_deint_syms_array(:);
                    P_pseudo_deint_vector = P_pseudo_deint_syms_array(:);
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% remove offset    (Check separately)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %         I_pseudo_deint_vector = I_pseudo_code;
                    %         P_pseudo_deint_vector = P_pseudo_code;
                    
                    assert(offset >= 0)
                    I_rx_softbits_deint = I_pseudo_deint_vector(1:end - offset);
                    P_rx_softbits_deint = [I_pseudo_deint_vector(end - (offset - 1):end) ; P_pseudo_deint_vector];
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% depuncture softbits
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Multiply by ~40 since these are soft-bits
                    % I_rx_softbits_deint = 40*I_msg_code;
                    % P_rx_softbits_deint = 40*P_msg_code;
                    
                    I_rx_softbits_depunc = wifi_softDepuncture(I_rx_softbits_deint, nbits, rt120);
                    P_rx_softbits_depunc = wifi_softDepuncture(P_rx_softbits_deint, nbits, rt120);
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% decode softbits
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %discard pad bits
                    n_bits_to_keep_I = (I_base_msg_len_bits + 16 + 6) * 2;
                    n_bits_to_keep_P = (P_base_msg_len_bits + 16 + 6) * 2;
                    
                    I_rx_softbits_depunc = I_rx_softbits_depunc(1:n_bits_to_keep_I);
                    P_rx_softbits_depunc = P_rx_softbits_depunc(1:n_bits_to_keep_P);
                    
                    %function [ dmsg ] = wifi_vdec(incode, nbits, tblen, initmetric, initstates, initinputs)
                    I_rx_decoded_bits = wifi_vdec(I_rx_softbits_depunc, nbits, tblen);
                    P_rx_decoded_bits = wifi_vdec(P_rx_softbits_depunc, nbits, tblen);
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% descramble bits
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %         I_rx_decoded_bits = I_msg_scr;
                    %         P_rx_decoded_bits = P_msg_scr;
                    
                    [I_rx_descrambled_bits I_descr_seq] = wifi_descramble(I_rx_decoded_bits);
                    [P_rx_descrambled_bits P_descr_seq] = wifi_descramble(P_rx_decoded_bits);
                    
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% Remove Service, tail and pad bits
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %         I_rx_descrambled_bits = I_msg_stp;
                    %         P_rx_descrambled_bits = P_msg_stp;
                    %
                    I_rx_service_field = I_rx_descrambled_bits(1:16);
                    I_rx_data_field = I_rx_descrambled_bits(16+1:16+I_base_msg_len_bits);
                    I_rx_tail_field = I_rx_descrambled_bits(16+I_base_msg_len_bits+1:end);
                    
                    P_rx_service_field = P_rx_descrambled_bits(1:16);
                    P_rx_data_field = P_rx_descrambled_bits(16+1:16+P_base_msg_len_bits);
                    P_rx_tail_field = P_rx_descrambled_bits(16+P_base_msg_len_bits+1:end);
                    
                    %% BER
                    
                    I_bit_errors = I_bit_errors + norm(I_rx_data_field - I_base_msg, 1);
                    P_bit_errors = P_bit_errors + norm(P_rx_data_field - P_base_msg, 1);
                    
                    I_length = I_length + I_base_msg_len_bits;
                    P_length = P_length + P_base_msg_len_bits;
                    
                    [I_bit_errors/I_length, P_bit_errors/P_length]
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% convert back from binary
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    I_rx_bits = reshape(I_rx_data_field, nb_bin_conv, [])';
                    I_rx_msg_e = vidwifi_bin2dec(I_rx_bits);
                    
                    P_rx_bits = reshape(P_rx_data_field, nb_bin_conv, [])';
                    P_rx_msg_e = vidwifi_bin2dec(P_rx_bits);
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% concatenate chunks
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    I_rx_stream = [I_rx_stream; I_rx_msg_e];
                    P_rx_stream = [P_rx_stream; P_rx_msg_e];
                end
            end
            
            UEP_BIT_ERRORS(snr) = [I_bit_errors/I_length, P_bit_errors/P_length, (I_bit_errors + P_bit_errors)/(I_length + P_length)];
            
        end
        
        save(strcat('uep_ber_', num2str(rate),'_', num2str(P_to_I)), 'UEP_BIT_ERRORS');
        
        
        %==== WiFi: TX CHAIN
        
        nvid_elpp = nBytes_payload;
        vid_stream = [I_tx_stream; P_tx_stream];
        vid_stream_size = length(vid_stream);
        
        npad = nPayloads*nvid_elpp - vid_stream_size;
        assert(npad == 0, 'Zero padding violated.')
        
        WiFi_VAL = cell(1, nPayloads);
        
        for iter = 1:nPayloads
            iter;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% pick the message
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %% Pick out chunk
            vid_str_end = length(vid_stream);
            vid_msg = vid_stream((iter-1)*nvid_elpp + 1 : min(iter*nvid_elpp, vid_str_end));
            
            %% Convert to binary
            vid_msg = dec2bin(vid_msg, nb_bin_conv);
            vid_msg = vid_msg';
            vid_msg = reshape(vid_msg, [], 1);
            vid_msg = str2num(vid_msg);
            vid_base_msg = vid_msg;
            vid_base_msg_len_bits = length(vid_base_msg);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% prepare the message with service, tail and pad bits
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            service = zeros(16,1);
            tail = zeros(6,1);
            vid_msg = [service; vid_msg; tail];
            
            npad = ceil(length(vid_msg)/ndbps) * ndbps - length(vid_msg);
            vid_msg = [vid_msg; zeros(npad, 1)];
            
            n_ofdm_syms = length(vid_msg)/ndbps;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% scramble the message
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            src_initstate = [1 0 1 1 1 0 1];
            [vid_msg_scr vid_scr_seq] = wifi_scramble(vid_msg, src_initstate);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% zero-out tail portion after scrambling
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            vid_msg_scr(16 + vid_base_msg_len_bits + 1:16 + vid_base_msg_len_bits + 6) = 0;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% code and puncture
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            vid_msg_code = wifi_cenc(vid_msg_scr, rt120);
            %coded_message_soft_bits = coded_message * scale;
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% arrange coded bits as symbols
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            vid_msg_code_syms = reshape(vid_msg_code, ncbps, n_ofdm_syms);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% interleave the bits
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            vid_msg_int_syms = wifi_interleave(vid_msg_code_syms, ncbps);
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% map bits onto constellation symbols
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            vid_mapped_syms = [];
            for i = 1:n_ofdm_syms
                vid_mapped_syms = [vid_mapped_syms wifi_map(vid_msg_int_syms(:,i), nbpsc)];
            end
            vid_samples_f = reshape(vid_mapped_syms, numel(vid_mapped_syms), 1);
            
            %--------------------------------------------------------------------------
            WiFi_VAL{iter} = struct('vid_samples_f', vid_samples_f,...
                'n_ofdm_syms', n_ofdm_syms,...
                'vid_base_msg_len_bits', vid_base_msg_len_bits,...
                'vid_base_msg', vid_base_msg);
            
        end
        
        %=== WiFi: CHANNEL + RX Chain
        WIFI_BIT_ERRORS = containers.Map('KeyType', 'double', 'ValueType', 'any');
        
        for snr = snr_val
            
            switch no_noise
                case 0
                    %snr = 30; % 18, 5
                case 1
                    snr = Inf;
            end
            vid_bit_errors = 0;
            vid_length = 0;
            for trial = 1:nTrials
                
                vid_rx_stream = [];
                
                
                for iter = 1:nPayloads
                    vid_samples_f = WiFi_VAL{iter}.vid_samples_f;
                    n_ofdm_syms = WiFi_VAL{iter}.n_ofdm_syms;
                    vid_base_msg = WiFi_VAL{iter}.vid_base_msg;
                    vid_base_msg_len_bits = WiFi_VAL{iter}.vid_base_msg_len_bits;
                    
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% let's add some AWGN noise
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    switch no_noise
                        case 0
                            vid_rx_samples_f = awgn(vid_samples_f, snr, 'measured');
                        case 1
                            vid_rx_samples_f = vid_samples_f;
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% demap symbols
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %function softbits = wifi_softSlice(points, nbpsc, nbits, range)
                    vid_rx_syms = reshape(vid_rx_samples_f, length(vid_rx_samples_f)/n_ofdm_syms, n_ofdm_syms);
                    vid_rx_syms_softbits = [];
                    for i = 1:n_ofdm_syms
                        vid_rx_syms_softbits = [vid_rx_syms_softbits wifi_softSlice(vid_rx_syms(:,i), nbpsc, nbits)];
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% deinterleave softbits
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    t = wifi_deinterleaveTables();
                    vid_rx_syms_deint = wifi_deinterleave(t, vid_rx_syms_softbits, nbpsc);
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% depuncture softbits
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    vid_rx_softbits_deint = reshape(vid_rx_syms_deint, numel(vid_rx_syms_deint), 1);
                    vid_rx_softbits_depunc = wifi_softDepuncture(vid_rx_softbits_deint, nbits, rt120);
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% decode softbits
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %discard pad bits
                    n_bits_to_keep = (vid_base_msg_len_bits + 16 + 6) * 2;
                    vid_rx_softbits_depunc = vid_rx_softbits_depunc(1:n_bits_to_keep);
                    %function [ dvid_msg ] = wifi_vdec(incode, nbits, tblen, initmetric, initstates, initinputs)
                    vid_rx_decoded_bits = wifi_vdec(vid_rx_softbits_depunc, nbits, tblen);
                    
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% descramble bits
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    [vid_rx_descrambled_bits descr_seq] = wifi_descramble(vid_rx_decoded_bits);
                    
                    vid_rx_service_field = vid_rx_descrambled_bits(1:16);
                    vid_rx_data_field = vid_rx_descrambled_bits(16+1:16+vid_base_msg_len_bits);
                    vid_rx_tail_field = vid_rx_descrambled_bits(16+vid_base_msg_len_bits+1:end);
                    
                    % Compute BER
                    vid_bit_errors = norm(vid_rx_data_field - vid_base_msg);
                    vid_length = vid_length +  vid_base_msg_len_bits;
                    
                    
                    vid_rx_bits = reshape(vid_rx_data_field, nb_bin_conv, [])';
                    vid_rx_stream = [vid_rx_stream; vidwifi_bin2dec(vid_rx_bits)];
                    
                end
                
                % Average BER
                
            end
            WIFI_BIT_ERRORS(snr) = [vid_bit_errors/vid_length];
        end
        save(strcat('wifi_ber_', num2str(rate), '_', num2str(P_to_I)), 'WIFI_BIT_ERRORS');
        
    end
end

