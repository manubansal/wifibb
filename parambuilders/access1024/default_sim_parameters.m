function [sim_params] = default_sim_parameters()
%DEFAULT parameters for the simulations 
    sim_params.tag 			= 'lte1024';
    sim_params.fftlen = 1024; 
    sim_params.sig_syms = 1;
    sim_params.rate_chart = ... % same MCSes as WiFi-64@20M
                            ... % but 48/64 -> 576/1024, 20MHz -> 15.36MHz
        [3.4560, 5.1840, 6.9120, 10.3680, 13.8240, 20.7360, 27.6480, 31.1040];   
    
    
    sim_params.rate = 31.1040; 
    sim_params.rate_sig = 3.4560; 
    
    sim_params.msglen = 500;
    
    sim_params.service_bits = 16;
    sim_params.tail_bits = 6;

    sim_params.scrambler_init = [1 0 1 1 1 0 1];
end

