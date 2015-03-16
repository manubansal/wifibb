function [opt] = wifi_common_parameters(opt, sim_params)

if nargin < 2
sim_params = default_sim_parameters;
end

fftlen = sim_params.fftlen;

opt.sample_duration_sec=50e-9;	%sample duration

%% STF
opt.stf_len = 160;		%no. of samples
opt.stf_shift_len = 80;	%used for cfo estimation

opt.stf_period = 16;
opt.num_stf_periods = 10;

opt.short_sync_freq_domain = zeros(64,1);
index_offset = 33;
%NOTE: SQRT(13/6) IS 1.472
opt.short_sync_freq_domain(-24 + index_offset) = 1.472 + 1.472*1i;
opt.short_sync_freq_domain(-20 + index_offset) = -1.472 - 1.472*1i;
opt.short_sync_freq_domain(-16 + index_offset) = 1.472 + 1.472*1i;
opt.short_sync_freq_domain(-12 + index_offset) = -1.472 - 1.472*1i;
opt.short_sync_freq_domain(-8 + index_offset)  = -1.472 - 1.472*1i;
opt.short_sync_freq_domain(-4 + index_offset)  = 1.472 + 1.472*1i;
opt.short_sync_freq_domain(4 + index_offset)   = -1.472 - 1.472*1i;
opt.short_sync_freq_domain(8 + index_offset)   = -1.472 - 1.472*1i;
opt.short_sync_freq_domain(12 + index_offset)  = 1.472 + 1.472*1i;
opt.short_sync_freq_domain(16 + index_offset)  = 1.472 + 1.472*1i;
opt.short_sync_freq_domain(20 + index_offset)  = 1.472 + 1.472*1i;
opt.short_sync_freq_domain(24 + index_offset)  = 1.472 + 1.472*1i;

%% Pilot Subcarrier Sequence Generator %
opt.pilot_sc=[ 1,1,1,1, -1,-1,-1,1, -1,-1,-1,-1, 1,1,-1,1, -1,-1,1,1,...
    -1,1,1,-1, 1,1,1,1, 1,1,-1,1, 1,1,-1,1, 1,-1,-1,1, 1,1,-1,1, ...
    -1,-1,-1,1, -1,1,-1,-1, 1,-1,-1,1, 1,1,1,1, -1,-1,1,1,...
    -1,-1,1,-1, 1,-1,1,1, -1,-1,-1,1, 1,-1,-1,-1, -1,1,-1,-1, ...
    1,-1,1,1, 1,1,-1,1, -1,1,-1,1, -1,-1,-1,-1, -1,1,-1,1, 1,-1,1,-1,...
    1,1,1,-1, -1,1,-1,-1, -1,1,1,1, -1,-1,-1,-1, -1,-1,-1 ];

if (fftlen == 1024) % Added by RM for ATT demo
    opt.sample_duration_sec = 1/(15.36e6);	%sample duration @fs=15.36MHz
    
    opt.cp_len_s = 256;
    opt.cp_skip = 256;
    opt.cp_len_s_ltf = 256;
    opt.cp_skip_ltf = 256;
    opt.cplen = [256 256 256 256];
    
    opt.fft_size = 1024;
    
    opt.nsubc = 1024;
    opt.ndatasubc = 576;
    opt.npsubc = 48;
    % NOTE: If we were to scale up WiFi-64 params, there should be 768/64
    % data/pilot symbols respectively, however at fs = 15.36 MHz (which is
    % the sampling frequency for 10 MHz LTE, needed to coexist
    % with Access Tx samples from ltesystb) that would correspond to an
    % occupied bandwidth of (768 + 64 + 1[dc])/1024*15.36 = 12.495 MHz.
    % However we need to restrict the Tx bandwidth to under 10 MHz, hence
    % the data/pilot symbols have been chosen to be 576/48 which occupies 
    % (576 + 48 + 1)/1024*15.36 = 9.375 MHz.
    
    %% PILOT subcarriers
    opt.psubc_idx = 208:13:819;
    opt.dsubc_idx = setdiff([201:512 514:825], opt.psubc_idx);
    opt.d1subc_idx = [1 512 514 1024];
        
    opt.intrasym_pilot_sc = [1,1,1,1, -1,-1,-1,1, -1,-1,-1,-1, 1,1,-1,1, ...
        -1,-1,1,1, -1,1,1,-1, 1,1,1,1, 1,1,-1,1, 1,1,-1,1, 1,-1,-1,1, ...
        1,1,-1,1, -1,-1,-1,1];
    
    %% LTF
    opt.ltf_shift_len= 1024;	%used for cfo estimation
    ltf_freq_left = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1];
    ltf_freq_right = [1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1];
    opt.ltf_sync_freq_domain = [repmat(ltf_freq_left, 1, 12), 0, repmat(ltf_freq_right, 1, 12)]';
    opt.ltf_sync_freq_domain = [ zeros(200,1); opt.ltf_sync_freq_domain; zeros(199,1)];
end

if (fftlen == 512)
    opt.cp_len_s = 128;
    opt.cp_skip = 128;
    opt.cp_len_s_ltf = 128;
    opt.cp_skip_ltf = 128;
    opt.cplen = [128 128 128 128];
    
    opt.fft_size = 512;
    
    opt.nsubc = 512;
    opt.ndatasubc = 384;
    opt.npsubc = 32;
    
    
    %% PILOT subcarriers
    opt.psubc_idx = 56:13:459;
    opt.dsubc_idx = setdiff([49:256 258:465], opt.psubc_idx);
    opt.d1subc_idx = [1 256 258 512];
        
    opt.intrasym_pilot_sc = [1,1,1,1, -1,-1,-1,1, -1,-1,-1,-1, 1,1,-1,1, -1,-1,1,1,...
        -1,1,1,-1, 1,1,1,1, 1,1,-1,1];
    
    %% LTF
    opt.ltf_shift_len=512;	%used for cfo estimation
    ltf_freq_left = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1];
    ltf_freq_right = [1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1];
    opt.ltf_sync_freq_domain = [repmat(ltf_freq_left, 1, 8), 0, repmat(ltf_freq_right, 1, 8)]';
    opt.ltf_sync_freq_domain = [ zeros(48,1); opt.ltf_sync_freq_domain; zeros(47,1)];
end

if (fftlen == 64)
    opt.cp_len_s = 16;
    opt.cp_skip = 16;
    opt.cp_len_s_ltf = 16;
    opt.cp_skip_ltf = 16;
    opt.cplen = [16 16 16 16];
    
    opt.fft_size = 64;
    
    opt.nsubc = 64;
    opt.ndatasubc = 48;
    opt.npsubc = 4;
    
    %% PILOT subcarriers
    opt.nsubc = 64;
    opt.psubc_idx = (opt.nsubc/2)+[(1+[-21 -7 7 21])];					%regular order (dc in middle)
    opt.dsubc_idx = (opt.nsubc/2)+[(1+[-26:-22 -20:-8 -6:-1]) (1+[1:6 8:20 22:26])];	%regular order (dc in middle)
    opt.d1subc_idx = (opt.nsubc/2)+[(1+[-32 -1 1 32])];
    
    opt.intrasym_pilot_sc = [1,-1,1,1];
    
    %% LTF
    opt.ltf_shift_len=64;	%used for cfo estimation
    ltf_freq_left = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1];
    ltf_freq_right = [1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1];
    opt.ltf_sync_freq_domain = [ltf_freq_left, 0, ltf_freq_right]';
    opt.ltf_sync_freq_domain = [ zeros(6,1); opt.ltf_sync_freq_domain; zeros(5,1)];
end

%% derived parameters
opt.sig_len = opt.fft_size + opt.cp_len_s;			%no. of samples in signal field
opt.sym_len_s = opt.fft_size + opt.cp_len_s;
opt.ltf_len = 2 * opt.fft_size + 2 * opt.cp_len_s_ltf;			%no. of samples
opt.pkt_start_pnt_shift_back_bias_s = opt.cp_len_s/2;	%shift-back the detected pkt start point

%% WIFI specifics
opt.wifi_nbpsc = [1, 1, 2, 2, 4, 4, 6, 6];
opt.wifi_rt120 = [60, 90, 60, 90, 60, 90, 80, 90];

end
