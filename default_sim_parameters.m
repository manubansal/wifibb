function [sim_params] = default_sim_parameters()
%DEFAULT parameters for the simulations 
    sim_params.tag = 'debug64';
    
    sim_params.fftlen = 1024; % 64 (WiFi-64)
    sim_params.rate = 31.1040; % 54 (WiFi-64)
    sim_params.rate_sig = 3.4560; % 6 (WiFi-64)
    sim_params.sig_syms = 1;
    sim_params.rate_chart = ... % same MCSes as WiFi-64@20M
                            ... % but 48/64 -> 576/1024, 20MHz -> 15.36MHz
        [3.4560, 5.1840, 6.9120, 10.3680, 13.8240, 20.7360, 27.6480, 31.1040];   
%     sim_params.rate_chart = ...
%         [6, 9, 12, 18, 24, 36, 48, 54]; % WiFi-64
    
    sim_params.snr = 25;
    sim_params.msglen = 500;
 
    
    sim_params.nmsgs = 2;
    sim_params.ch = 'passthrough';
    
    sim_params.zero_prepad_dur_us = 25; 
        % Changed from 10 in WiFi-64 to 25 so that number of samples at
        % 15.36 MHz is an integer
        
    sim_params.zero_postpad_dur_us = 25; 
        % Changed from 10 in WiFi-64 to 25 so that number of samples at 
        % 15.36 MHz is an integer    
    
    sim_params.service_bits = 16;
    sim_params.tail_bits = 6;

    sim_params.scrambler_init = [1 0 1 1 1 0 1];
    
end

