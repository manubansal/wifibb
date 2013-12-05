function [opt, stats] = wifi_rx_parameters(scale, mod, opt)
  [DATA_DIR, TRACE_DIR] = setup_paths()

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % user configuration
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %tx packet parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  if (nargin < 3)

    %------------ begin trace parameters ---------------
    %opt.trace.traceFolder = 'traces/';
    %opt.trace.traceFolder = 'traces-decim/'
    %opt.trace.traceFolder = 'traces-sbx-decim/'
    %opt.trace.traceFolder = 'traces-wifi-sbx-decim/'

    %opt.trace.traceFolder = '../wifibb-traces/traces-wifi-sbx-decim/'
    opt.trace.traceFolder = strcat(TRACE_DIR, '/traces-wifi-sbx-decim/')

    %scale = 1;			%factor by which to scale down the samples (so this cuts down the tx gain (linear)
    if (nargin < 1)
      %scale = 1;			%factor by which to scale down the samples (so this cuts down the tx gain (linear)
      scale = '1';			%factor by which to scale down the samples (so this cuts down the tx gain (linear)
    else
      s = whos('scale');
      c = s.class;
      if ((length(c) ~= 4) || (sum(c == 'char') ~= 4))
	display('"scale" should be input as a string. Did you input it as a number?');
	error('wrongInputType','scale is wrong data type');
      end
    end

    %opt.trace.mod = 1;			%tx modulation scheme, bpsk is 1, qpsk is 2

    if (nargin < 2)
      %%%%%%%%opt.trace.mod = '54M';			%tx modulation scheme, bpsk is 1, qpsk is 2
      opt.trace.mod = '54M';			%tx modulation scheme, bpsk is 1, qpsk is 2
      %opt.trace.mod = '48M';			%tx modulation scheme, bpsk is 1, qpsk is 2
      %opt.trace.mod = '36M';			%tx modulation scheme, bpsk is 1, qpsk is 2
      %opt.trace.mod = '24M';			%tx modulation scheme, bpsk is 1, qpsk is 2
      %opt.trace.mod = '18M';			%tx modulation scheme, bpsk is 1, qpsk is 2
    else 
      opt.trace.mod = mod;
    end

    %opt.trace.nsyms_data = 250;			%tx packet length in ofdm symbols
    %opt.trace.nsyms_data = '20';			%tx packet length in ofdm symbols
    %opt.trace.nsyms_data = '100Bping';			%tx packet length in ofdm symbols
    opt.trace.nsyms_data = '100Budp_rev';			%tx packet length in ofdm symbols

    opt.trace.scale = scale;

    %opt.trace.rxgain = 35;
    opt.trace.rxgain = 0;
    %opt.trace.atten = '26';
    %opt.trace.atten = '20cm';
    %opt.trace.atten = '20.30.10';		%main tx atten, main rx atten, rx atten on the RF T junction
    %opt.trace.atten = '20.10.30';
    opt.trace.atten = '20.20.30';
    %------------ end of trace parameters ---------------


    opt.tx_known = false;		%tx data is known, so ibits, qbits, syms are also loaded for comparison/ber

    opt.ti_factor = 1024 * 32; %15 bits
    opt.ti_factor_after_cfo = 1024 * 32 * 2; %15 bits

    opt.n_decoded_symbols_per_ofdm_symbol = 4;	%a 216 bit symbol is decoded as 4 54-bit symbols with parallel viterbi

    opt.COARSE_CFO_CORRECTION = true;
    opt.FINE_CFO_CORRECTION = true;
    opt.PILOT_PHASE_TRACKING = true;
    opt.PILOT_SAMPLING_DELAY_CORRECTION = true;	%this is really referring to sampling delay 
							  %introduced due to sampling frequency offset
    opt.GENERATE_ONE_TIME_PLOTS = false;
    opt.GENERATE_PER_PACKET_PLOTS = false;
    opt.PAUSE_AFTER_EVERY_PACKET = true;

    %---- these are written to c files ready to be imported for debugging ------%
    opt.writeVars_corr = false;
    opt.writeVars_startPnts = false;
    opt.writeVars_cfos = true;
    opt.writeVars_deinterleave = true;
    opt.writeVars_depuncture = true;
    opt.writeVars_decode = true;


    %---- these are only being printed, but not written to files ------%
    opt.printVars_corr = false;
    opt.printVars_chEsts = false;
    opt.printVars_cfoCorrectedPlcp = true;
    opt.printVars_ofdmDemodPlcp = true;

    opt.printVars_ofdmEqualizedPlcp = true;
    opt.printVars_equalize = true;

    opt.printVars_softBits_plcp = true;
    opt.printVars_softBits_data = true;

    opt.printVars_deinterleave = true;
    opt.printVars_softBits_deint = true;

    opt.printVars_decodedBits = true;
    opt.printVars_descrambledBits = true;

    %----- all print after total data decode for the packet -----
    opt.printVars_data_syms = false;
    %opt.printVars_data_syms = true;

    %----- variable binary dumps ---------%
    opt.dumpVars_plcpBaseSamples = true;
    opt.dumpVars_plcpCfoCorrected = true;
    opt.dumpVars_plcpOfdmDemod = true;
    opt.dumpVars_plcpOfdmEq = true;
    opt.dumpVars_plcpDemap = true;

    opt.dumpVars_dataOfdmEq = true;
    opt.dumpVars_dataVitdecChunks = true;
    opt.dumpVars_dataVitdec = true;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % processing/analysis parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %opt.corr_threshold = 0.9;	%correlation threshold value to use for symbol timing acquisition/packet detection
  %opt.corr_threshold = 0.75;	%correlation threshold value to use for symbol timing acquisition/packet detection
  opt.corr_threshold = 0.7071;	%correlation threshold value to use for symbol timing acquisition/packet detection
  				%this particular value is sqrt(0.5), which means we can alternatively use 0.5 
				%for squared correlation magnitude

  opt.sq_corr_threshold = 0.5;

  %corr_threshold = 0.6;		%correlation threshold value to use for symbol timing acquisition/packet detection
  %Note: correlation value at the actual packet start point will ideally be 1, but even with infinite SNR, it'll be 
  %less than 1 due to multipath distortion of the preamble. As SNR degrades, so will the correlation value as noise 
  %starts hiding the preamble's structure. Thus, this value is a delicate choice. Making it too low will lead to many
  %false positives, especially if noise is non-white due to non-flat system response, and making it too high will 
  %lead to many false negatives at lower SNRs, thus missing valid packets. Perhaps it's best to keep this a function
  %of SNR. Though reliable SNR can only be known after detecting and decoding a packet, an SNR estimate can be obtained
  %upon detecting energy jumps on the channel.

  opt.ns_ofdm_phy_preamble_signal = 80 * 2 + 80 * 2 + 80;	%stf, ltf, signal
  %this is the minimum number of samples from the peak detect point that we need for decoding at least
  %the signal field and to consider the packet at all

  %opt.peak_search_win_delta = 100;
  %opt.peak_search_win_size = 1000;
  opt.peak_search_win_size = 80 * 2;

  %opt.pkt_period_samples = 22320;	%no. of samples between start of two packets (as transmitted)
  %opt.pkt_length_samples = 20320;	%no. of samples in a packet, including preamble but not the extra windowing term
  %opt.max_pkt_length_samples = (1500*8/6)*20 + opt.ns_ofdm_phy_preamble_signal;	%no. of samples in a 1500B pkt at 6Mbps

  opt.max_nsyms_data = 501;
  opt.max_pkt_length_samples = (opt.max_nsyms_data*80) + opt.ns_ofdm_phy_preamble_signal;	
  										%no. of samples with 500 ofdm syms (1500B/24bits - 
  										%at 6Mbps, one symbol as 24 data bits), with 
											%1 additional symbol due to service and tail bits

  opt.ns_to_skip = 400000;
  %opt.ns_to_skip = 400000 + 80 * 24;
  %opt.ns_to_skip = 400000 + 80 * 64;
  %opt.ns_to_skip = 800000;		%no. of samples to discard from the beginning
  %opt.ns_to_skip = 0;		%no. of samples to discard from the beginning
  %ns_to_skip = 1000;		%no. of samples to discard from the beginning

  opt.ns_to_process = 100000;	%no. of samples to process (must be at least pkt_period_samples)
  %opt.ns_to_process = 10000;	%no. of samples to process (must be at least pkt_period_samples)
  %opt.ns_to_process = 400000;	%no. of samples to process (must be at least pkt_period_samples)
  				%set to 0 to process till the end
  %ns_to_process = 0;
  %opt.ns_to_process = 80000;	%no. of samples to process (must be at least pkt_period_samples)

  opt.corrwin = 80; %no. of samples in a correlation window
  %opt.corrwin = 64; %no. of samples in a correlation window

  %opt.soft_slice_nbits = 6;
  opt.soft_slice_nbits = 7;

  %opt.tblen_signal = 24;
  %opt.tblen_data = 36;

  opt.tblen_signal = 18;
  opt.tblen_data = 18;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % rx parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %------------ begin derived trace parameters ---------------

  display(strcat('trace folder: ', opt.trace.traceFolder));

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %%traceFile = 'traces/t.dat';
  %%iBitsFile = 'data/ibits.mat'; %data bits matrix for I-channel
  %%qBitsFile = 'data/qbits.mat'; %data bits matrix for Q-channel
  %%symbsFile = 'data/symbs.mat';	%modulated data symbols matrix

  
  %dt = datestr(now, 'yyyymmdd_HHMMSS')

  %txpktparams = strcat('nsyms_',int2str(nsyms),'_mod_',int2str(mod),'_scale_',num2str(scale));
  %rxpktparams = strcat('nsyms_',int2str(nsyms),'_mod_',int2str(mod),'_scale_',num2str(scale),'_atten_',atten,'_rxgain_',int2str(rxgain));

  opt.trace.txpktparams = strcat('nsyms_',opt.trace.nsyms_data,'_mod_',opt.trace.mod,'_scale_',opt.trace.scale);
  opt.trace.rxpktparams = strcat('nsyms_',opt.trace.nsyms_data,'_mod_',opt.trace.mod,'_scale_',opt.trace.scale,'_atten_',opt.trace.atten,'_rxgain_',int2str(opt.trace.rxgain));

  %opt.trace.nsyms_data
  opt.trace.nsyms_data = str2num(opt.trace.nsyms_data);
  %opt.trace.nsyms_data

  if (prod(size(opt.trace.nsyms_data)) == 0)
    opt.trace.nsyms_data = opt.max_nsyms_data;
  end
  %opt.trace.nsyms_data
  %pause

  opt.trace.mod = str2num(opt.trace.mod);

  %rxpkts_nsyms_250_mod_1_scale_256_atten_30_rxgain_35
  %traceFile = strcat('traces/rxpkts_',rxpktparams,'.dat')
  opt.trace.traceFile = strcat(opt.trace.traceFolder,'/rxpkts_',opt.trace.rxpktparams,'.dat')
  opt.trace.iBitsFile = strcat('data/ibits_',opt.trace.txpktparams,'.mat'); %data bits matrix for I-channel
  opt.trace.qBitsFile = strcat('data/qbits_',opt.trace.txpktparams,'.mat'); %data bits matrix for Q-channel
  opt.trace.symbsFile = strcat('data/symbs_',opt.trace.txpktparams,'.mat');	%modulated data symbols matrix

  %iBitsFile = strcat('data/ibits_nsyms_',int2str(nsyms),'_mod_',int2str(mod),'.mat');
  %qBitsFile = strcat('data/qbits_nsyms_',int2str(nsyms),'_mod_',int2str(mod),'.mat');
  %------------ end derived trace parameters ---------------




  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  opt.noise_win_len=256;		%no. of samples to compute noise over (keep at least 10 and a multiple of noise_fft_size)
  opt.noise_fft_size=64;		
  opt.stf_len=160;			%no. of samples
  opt.ltf_len=160;			%no. of samples
  opt.sig_len=80;			%no. of samples in signal field
  opt.stf_shift_len=80;
  opt.ltf_shift_len=64;
  opt.sample_duration_sec=50e-9;	%sample duration

  opt.sym_len_s = 80;
  opt.cp_len_s = 16;
  opt.fft_size = 64;
  %opt.cp_skip = 8;
  opt.cp_skip = 16;
  %opt.cp_skip = 12;

  opt.ftype.data 	= 0;
  opt.ftype.ack 	= 1;
  opt.ftype.unknown 	= 2;
  data.frame_type	= opt.ftype.unknown;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  display('tx and rx parameters of the experiment:');


  %% HACK to make sure trace is not being used %%
  opt.trace = {}

  opt




  %----------------------------------------

  stats.idle_noise_power = [];
  stats.stf_power = [];
  stats.ltf_power = [];
  stats.sig_power = [];
  stats.data_power = [];
  stats.pkt_power = [];

  stats.snr_lin = [];
  stats.snr_db = [];

  stats.coarse_cfo_angle_corr = [];
  stats.coarse_cfo_freq_off_khz = [];

  stats.fine_cfo_angle_corr = [];
  stats.fine_cfo_freq_off_khz = [];

  stats.ber = [];

  stats.n_bits_errors_i = [];

  stats.net_snr_linear = [];
  stats.net_snr_db = [];

  stats.n_bits_errors_q = [];

  stats.ber_vs_ofdm_symbol = [];
  stats.snr_per_subcarrier = [];
  stats.snr_per_subcarrier_db = [];
  stats.ber_vs_subcarrier = [];

  stats.n_packets_processed = 0;
  stats.pkt_start_points = [];

  stats.min_max_corr_val = 2.0;
  stats.max_max_corr_val = 0.0;


  stats.ber_vec_data = [];
  stats.crc_vec_data = [];

  stats.ber_vec_ack = [];
  stats.crc_vec_ack = [];

  stats.ber_vec_unknown = [];
  stats.crc_vec_unknown = [];


  stats.uu_ltf1_data = []; stats.uu_ltf2_data = []; stats.ch_data = [];
  stats.uu_ltf1_ack = []; stats.uu_ltf2_ack = []; stats.ch_ack = [];
  stats.uu_ltf1_unknown = []; stats.uu_ltf2_unknown = []; stats.ch_unknown = [];

  stats.all_ltf1_64 = [];
  stats.all_ltf2_64 = [];
  stats.all_ltf_av_64 = [];
  stats.all_channel_64 = [];

  %----------------------------------------
end
