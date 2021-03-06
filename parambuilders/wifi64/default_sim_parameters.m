function [sim_params] = default_sim_parameters()
%DEFAULT parameters for the simulations 
    sim_params.tag 			= 'debug64';
    
    sim_params.fftlen 			= 64;
    sim_params.rate 			= 54;
    sim_params.rate_sig 		= 6;
    sim_params.sig_syms 		= 1;
    sim_params.rate_chart 		= [6, 9, 12, 18, 24, 36, 48, 54];
    
    sim_params.snr 			= 25;
    sim_params.msglen 			= 500;
 
    
    sim_params.nmsgs 			= 2;
    sim_params.ch 			= 'passthrough';
    
    sim_params.zero_prepad_dur_us 	= 10; 
        
    sim_params.zero_postpad_dur_us 	= 10; 
    
    sim_params.service_bits 		= 16;
    sim_params.tail_bits 		= 6;

    sim_params.scrambler_init 		= [1 0 1 1 1 0 1];
    
end

