function [opt] = wifi_common_parameters(opt)
sim_params = default_sim_parameters;
fftlen = sim_params.fftlen;

opt.sample_duration_sec=50e-9;	%sample duration

%% STF
opt.stf_len = 160;								%no. of samples
opt.stf_shift_len=80;	%used for cfo estimation

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
    opt.psubc_idx = [56:13:459];
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
    opt.d1subc_idx = [1 31 33 64];
    
    opt.intrasym_pilot_sc = [1,1,-1,1];
    
    %% LTF
    opt.ltf_shift_len=64;	%used for cfo estimation
    ltf_freq_left = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1];
    ltf_freq_right = [1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1];
    opt.ltf_sync_freq_domain = [repmat(ltf_freq_left, 1, 1), 0, repmat(ltf_freq_right, 1, 1)]';
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
