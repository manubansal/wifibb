function opt = wifi_rx_parameters(scale, mod, opt)
  %[DATA_DIR, TRACE_DIR] = setup_paths();
  TRACE_DIR = getenv('TRACE_DIR');
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % user configuration
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %tx packet parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  if (nargin < 3 || strcmp(opt, 'null'))

    %------------ begin trace parameters ---------------
    %opt.trace.traceFolder = 'traces/';
    %opt.trace.traceFolder = 'traces-decim/'
    %opt.trace.traceFolder = 'traces-sbx-decim/'
    %opt.trace.traceFolder = 'traces-wifi-sbx-decim/'

    %opt.trace.traceFolder = '../wifibb-traces/traces-wifi-sbx-decim/'
    opt.trace.traceFolder = strcat(TRACE_DIR, '/traces-wifi-sbx-decim/');

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

    %------------ begin rx chain dsp options -----------------
    opt.COARSE_CFO_CORRECTION = true;
    opt.FINE_CFO_CORRECTION = true;
    opt.PILOT_PHASE_TRACKING = true;
    opt.PILOT_SAMPLING_DELAY_CORRECTION = true;	%this is really referring to sampling delay introduced due to sampling frequency offset
    %opt.VITDEC_MODEL = 'TERM';			%optimal viterbi decoding on a terminated sequence
    opt.VITDEC_MODEL = 'CONVGT';		%convergent mode decoding with partial tracebacks
    opt.VITDEC_chunksize = 54;
    %opt.VITDEC_tblen = 18;
    %opt.VITDEC_tblen = 24;
    %opt.VITDEC_tblen = 36;
    opt.VITDEC_tblen = 54;
    %opt.VITDEC_tblen = 72;
    %------------ end rx chain dsp options -----------------


    %------------ begin UI options ---------------------
    opt.GENERATE_ONE_TIME_PLOTS_PRE = true;%
    opt.GENERATE_ONE_TIME_PLOTS_POST = false;

    opt.GENERATE_PER_PACKET_PLOTS_ONLY_ON_FILTER_MATCH = false;
    opt.GENERATE_PER_PACKET_PLOTS = false;%
    opt.GENERATE_PER_PACKET_PLOTS_CONSTELLATION = false;%
    opt.GENERATE_PER_PACKET_PLOTS_CHANNEL = false;%

    opt.PAUSE_AFTER_EVERY_PACKET = false;
    %------------ end UI options ---------------------


    %---- these are written to c files ready to be imported for debugging ------%
    opt.writeVars_corr = false;
    opt.writeVars_startPnts = false;
    opt.writeVars_cfos = false;
    opt.writeVars_deinterleave = false;
    opt.writeVars_depuncture = false;
    opt.writeVars_decode = false;


    %---- these are only being printed, but not written to files ------%
    opt.printVars_corr = false;
    opt.printVars_chEsts = false;
    opt.printVars_cfoCorrectedPlcp = false;
    opt.printVars_ofdmDemodPlcp = false;

    opt.printVars_ofdmEqualizedPlcp = false;
    opt.printVars_equalize = false;

    opt.printVars_softBits_plcp = false;
    opt.printVars_softBits_data = false;

    opt.printVars_deinterleave = false;
    opt.printVars_softBits_deint = false;

    opt.printVars_decodedBits = false;
    opt.printVars_descrambledBits = false;

    %----- all print after total data decode for the packet -----
    opt.printVars_data_syms = false;
    opt.printVars_parsedData = false;

    %----- variable binary dumps ---------%
    opt.dumpVars_ltfRxSamples = false;
    opt.dumpVars_plcpBaseSamples = false;

    opt.dumpVars_plcpCfoCorrected = false;
    opt.dumpVars_plcpOfdmDemod = false;
    opt.dumpVars_plcpOfdmEq = false;
    opt.dumpVars_plcpDemap = false;

    opt.dumpVars_dataBaseSamples = false;
    opt.dumpVars_dataCfoCorrected = false;
    opt.dumpVars_dataOfdmDemod = false;
    opt.dumpVars_dataOfdmEq = false;
    opt.dumpVars_dataDemap = false;
    opt.dumpVars_dataDepunct = false;
    opt.dumpVars_dataVitdecChunks = false;
    opt.dumpVars_dataVitdec = false;
    opt.dumpVars_dataDescr = false;
    opt.dumpVars_dataParsed = false;
  end

  opt = wifi_common_parameters(opt);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % processing/analysis parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %opt.corr_threshold = 0.9;	%correlation threshold value to use for symbol timing acquisition/packet detection
  %opt.corr_threshold = 0.75;	%correlation threshold value to use for symbol timing acquisition/packet detection
  opt.corr_threshold = 0.7071;	%correlation threshold value to use for symbol timing acquisition/packet detection
  				%this particular value is sqrt(0.5), which means we can alternatively use 0.5 
				%for squared correlation magnitude (easier implementation on the DSP)

  %opt.sq_corr_threshold = 0.81;
  opt.sq_corr_threshold = 0.5;

  %corr_threshold = 0.6;		%correlation threshold value to use for symbol timing acquisition/packet detection
  %Note: correlation value at the actual packet start point will ideally be 1, but even with infinite SNR, it'll be 
  %less than 1 due to multipath distortion of the preamble. As SNR degrades, so will the correlation value as noise 
  %starts hiding the preamble's structure. Thus, this value is a delicate choice. Making it too low will lead to many
  %false positives, especially if noise is non-white due to non-flat system response, and making it too high will 
  %lead to many false negatives at lower SNRs, thus missing valid packets. Perhaps it's best to keep this a function
  %of SNR. Though reliable SNR can only be known after detecting and decoding a packet, an SNR estimate can be obtained
  %upon detecting energy jumps on the channel.

  opt.ns_ofdm_phy_preamble_signal = opt.stf_len + opt.ltf_len + opt.sig_len;	%stf, ltf, signal
  %this is the minimum number of samples from the peak detect point that we need for decoding at least
  %the signal field and to consider the packet at all

  %opt.peak_search_win_delta = 100;
  %opt.peak_search_win_size = 1000;
  opt.peak_search_win_size = 80 * 2;

  %opt.pkt_period_samples = 22320;	%no. of samples between start of two packets (as transmitted)
  %opt.pkt_length_samples = 20320;	%no. of samples in a packet, including preamble but not the extra windowing term
  %opt.max_pkt_length_samples = (1500*8/6)*20 + opt.ns_ofdm_phy_preamble_signal;	%no. of samples in a 1500B pkt at 6Mbps

  opt.max_nsyms_data = 501;
  opt.max_pkt_length_samples = (opt.max_nsyms_data*opt.sym_len_s) + opt.ns_ofdm_phy_preamble_signal;	
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
  opt.trace.traceFile = strcat(opt.trace.traceFolder,'/rxpkts_',opt.trace.rxpktparams,'.dat');
  opt.trace.iBitsFile = strcat('data/ibits_',opt.trace.txpktparams,'.mat'); %data bits matrix for I-channel
  opt.trace.qBitsFile = strcat('data/qbits_',opt.trace.txpktparams,'.mat'); %data bits matrix for Q-channel
  opt.trace.symbsFile = strcat('data/symbs_',opt.trace.txpktparams,'.mat');	%modulated data symbols matrix

  %iBitsFile = strcat('data/ibits_nsyms_',int2str(nsyms),'_mod_',int2str(mod),'.mat');
  %qBitsFile = strcat('data/qbits_nsyms_',int2str(nsyms),'_mod_',int2str(mod),'.mat');
  %------------ end derived trace parameters ---------------




  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %opt.noise_win_len=256;		%no. of samples to compute noise over (keep at least 10 and a multiple of noise_fft_size)
  opt.noise_win_len=64;		%no. of samples to compute noise over (keep at least 10 and a multiple of noise_fft_size)
  opt.noise_fft_size=64;		
  


  opt.ftype.data 	= 0;
  opt.ftype.ack 	= 1;
  opt.ftype.unknown 	= 2;
  data.frame_type	= opt.ftype.unknown;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %display('tx and rx parameters of the experiment:');

  %% HACK to make sure trace is not being used %%
  opt.trace = {};

  %opt
end
