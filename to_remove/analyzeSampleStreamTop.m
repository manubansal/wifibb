function stats = analyzeSampleStream(scale, mod, opt)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % user configuration
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %tx packet parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

  if (nargin < 3)
    %opt.traceFolder = 'traces/';
    %opt.traceFolder = 'traces-decim/'
    %opt.traceFolder = 'traces-sbx-decim/'
    %opt.traceFolder = 'traces-wifi-sbx-decim/'
    opt.traceFolder = '../wifibb-traces/traces-wifi-sbx-decim/'
    %opt.mod = 1;			%tx modulation scheme, bpsk is 1, qpsk is 2

    if (nargin < 2)
      %%%%%%%%opt.mod = '54M';			%tx modulation scheme, bpsk is 1, qpsk is 2
      opt.mod = '54M';			%tx modulation scheme, bpsk is 1, qpsk is 2
      %opt.mod = '48M';			%tx modulation scheme, bpsk is 1, qpsk is 2
      %opt.mod = '36M';			%tx modulation scheme, bpsk is 1, qpsk is 2
      %opt.mod = '24M';			%tx modulation scheme, bpsk is 1, qpsk is 2
      %opt.mod = '18M';			%tx modulation scheme, bpsk is 1, qpsk is 2
    else 
      opt.mod = mod;
    end

    %opt.nsyms_data = 250;			%tx packet length in ofdm symbols
    %opt.nsyms_data = '20';			%tx packet length in ofdm symbols
    %opt.nsyms_data = '100Bping';			%tx packet length in ofdm symbols
    opt.nsyms_data = '100Budp_rev';			%tx packet length in ofdm symbols
    opt.scale = scale;
    %opt.rxgain = 35;
    opt.rxgain = 0;
    %opt.atten = '26';
    %opt.atten = '20cm';
    %opt.atten = '20.30.10';		%main tx atten, main rx atten, rx atten on the RF T junction
    %opt.atten = '20.10.30';
    opt.atten = '20.20.30';

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

    opt.printVars_decodedBits = true;
    opt.printVars_descrambledBits = false;

    %----- all print after total data decode for the packet -----
    opt.printVars_data_syms = false;
    %opt.printVars_data_syms = true;
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

  display(strcat('trace folder: ', opt.traceFolder));

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %rx parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %%traceFile = 'traces/t.dat';
  %%iBitsFile = 'data/ibits.mat'; %data bits matrix for I-channel
  %%qBitsFile = 'data/qbits.mat'; %data bits matrix for Q-channel
  %%symbsFile = 'data/symbs.mat';	%modulated data symbols matrix

  
  %dt = datestr(now, 'yyyymmdd_HHMMSS')

  %txpktparams = strcat('nsyms_',int2str(nsyms),'_mod_',int2str(mod),'_scale_',num2str(scale));
  %rxpktparams = strcat('nsyms_',int2str(nsyms),'_mod_',int2str(mod),'_scale_',num2str(scale),'_atten_',atten,'_rxgain_',int2str(rxgain));

  opt.txpktparams = strcat('nsyms_',opt.nsyms_data,'_mod_',opt.mod,'_scale_',opt.scale);
  opt.rxpktparams = strcat('nsyms_',opt.nsyms_data,'_mod_',opt.mod,'_scale_',opt.scale,'_atten_',opt.atten,'_rxgain_',int2str(opt.rxgain));

  %opt.nsyms_data
  opt.nsyms_data = str2num(opt.nsyms_data);
  %opt.nsyms_data
  if (prod(size(opt.nsyms_data)) == 0)
    opt.nsyms_data = opt.max_nsyms_data;
  end
  %opt.nsyms_data
  %pause

  opt.mod = str2num(opt.mod);

  %rxpkts_nsyms_250_mod_1_scale_256_atten_30_rxgain_35
  %traceFile = strcat('traces/rxpkts_',rxpktparams,'.dat')
  opt.traceFile = strcat(opt.traceFolder,'/rxpkts_',opt.rxpktparams,'.dat')
  opt.iBitsFile = strcat('data/ibits_',opt.txpktparams,'.mat'); %data bits matrix for I-channel
  opt.qBitsFile = strcat('data/qbits_',opt.txpktparams,'.mat'); %data bits matrix for Q-channel
  opt.symbsFile = strcat('data/symbs_',opt.txpktparams,'.mat');	%modulated data symbols matrix

  %iBitsFile = strcat('data/ibits_nsyms_',int2str(nsyms),'_mod_',int2str(mod),'.mat');
  %qBitsFile = strcat('data/qbits_nsyms_',int2str(nsyms),'_mod_',int2str(mod),'.mat');


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


%  samples = util_loadBinaryFile(opt.traceFile);
%  if (opt.ns_to_process == 0)
%    last_sample = length(samples);
%  else
%    last_sample = (opt.ns_to_process+opt.ns_to_skip);
%  end
%  samples = samples((1+opt.ns_to_skip):last_sample);
  samples = util_loadBinaryFilePart(opt.traceFile, opt.ns_to_process, opt.ns_to_skip);

  samples = samples.';

  if (opt.tx_known)
  load(opt.iBitsFile);		%tx data for BER computation
  load(opt.qBitsFile);		%tx data for BER computation
  data.tx_data_bits_i = databits_i; 
  data.tx_data_bits_q = databits_q;
  end
  data.mod = opt.mod;

  data.samples = samples;
  pilot_syms = generate_pilot_syms(opt.nsyms_data);
  %size(pilot_syms)
  %%%%data.sig_and_data_tx_pilot_syms = [pilot_syms(:,1) pilot_syms];	%NO! signal and data symbols draw from the same seq
  data.sig_and_data_tx_pilot_syms = [pilot_syms];
  %size(data.sig_and_data_tx_pilot_syms)
  %pause
  %data.pkt_start_point = -opt.pkt_length_samples;
  data.pkt_start_point = -1;

  %%% THIS 1
  %%%%display('------------------- begin detectPackets -------------------');
  %%%%tic;
  %%%%[stats data] = detectPackets(data, opt, stats);
  %%%%display('------------------- done detectPackets -------------------');
  %%%%toc

  %%%t = 0;
  %%%for i = 1:data.n_packets_detected
  %%%  display(strcat('-------------- packet #',int2str(i),' of #',num2str(data.n_packets_detected),' ---- '));
  %%%  display(strcat('-------------- last pkt took #',num2str(t),'s to process ----'));
  %%%  tic;
  %%%  data.pkt_start_point = stats.pkt_start_points(i);
  %%%  stats = analyzeSinglePacket(data, opt, stats);
  %%%  toc
  %%%  t = toc;
  %%%end
  %%% THIS 1

  %%% OR THIS 2
  display('------------------- begin findStreamCorrelation -------------------');
  tic;
  [stats data] = findStreamCorrelation(data, opt, stats);
  display('------------------- done findStreamCorrelation -------------------');
  toc

  data.deinterleave_tables = wifi_deinterleaveTables();

  t = 0;
  ber = 0;
  i = 0;
  %while (ber ~= -1) 
  while (data.pkt_start_point > -Inf)
    i = i + 1;
    display(strcat('-------------- scale: ',scale,', packet #',int2str(i),'-----------'));%,' of #',num2str(data.n_packets_detected),' ---- '));
    display(strcat('-------------- last pkt took #',num2str(t),'s to process ----'));

    tic;

    %detect next packet
    [stats data] = detectNextPacket(data, opt, stats);
    if (data.pkt_start_point == -1)
      break;
    end

    %if (data.pkt_start_point == -2)	%pkt_start_point was too early for us to find noise
    %  continue;			%don't analyze, since we couldn't get the right stats out
    %end

    if (data.pkt_start_point == -Inf)
      break;
    end


    %analyze next packet
    stats = analyzeSinglePacket(data, opt, stats);
    ber = stats.ber(end);

    %remove the analyzed packet from sample stream and associated data structures
    %%%data.samples(1:min(data.pkt_start_point+opt.pkt_length_samples-1,end)) = [];
    %%%data.corrvec(1:min(data.pkt_start_point+opt.pkt_length_samples-1,end)) = [];
    %%%data.abscorrvec(1:min(data.pkt_start_point+opt.pkt_length_samples-1,end)) = [];

    last_pkt_start_point = stats.pkt_start_points(end)
    max_corr_val = stats.max_corr_val

    toc
    t = toc;
    if (opt.PAUSE_AFTER_EVERY_PACKET)
      pause
    end
  end
  %%% THIS 2

  %display and summarize stats
  stats = summarizeStats(stats, data, opt);
  stats.opt = opt;
end


%----------------------------------------------------------------------------------------------------------------------------
function [stats data]= findStreamCorrelation(data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  %plotSamples(samples);
  samples = data.samples;
  corrwin = opt.corrwin;
  %corr_threshold = opt.corr_threshold;

  %stats.avg_stream_power = mean(abs(samples).^2);
  %stats.avg_stream_power_2 = power(samples);

  [corrvec abscorrvec abscorrvecsq norm1val norm2val normval norm1terms norm2terms] = wifi_streamCorrelation(samples, corrwin); 
  isMetricHigh = (abscorrvecsq >= opt.sq_corr_threshold);
  %toc
  %pause
  if (opt.writeVars_corr)
  writeVars_corr(corrvec, abscorrvec, abscorrvecsq, norm1val, norm2val, normval, corrwin, norm1terms, norm2terms, isMetricHigh);
  end
  %pause

  if (opt.printVars_corr)
	  format long e
	  ns = 6000;
	  i = [1:ns] + 160;
	  %c = corrvec(1:ns);
	  %c = abscorrvecsq(1:ns).*abscorrvecsq(1:ns);
	  c = abscorrvecsq(1:ns);
	  ci = [i; c]';
	  nbufs = ns/80;
	  for bufi=1:nbufs
		  corrvals = ci(((bufi-1)*80 + 1):(bufi*80),:)
		  pause
	  end
	  format short
  end


  %figure
  %plot(abs(corrvec))
  x = 1:length(abs(samples));

  if (opt.GENERATE_ONE_TIME_PLOTS)
    figure
    %plotyy(x, abs(samples), x, abscorrvec);
    title('Sample magnitudes and correlation magnitudes');
    plotyy(x, 10*log10(abs(samples)), x, abscorrvec);
    grid on

    figure
    %plotyy(x, abs(samples), x, abscorrvec);
    title('Sample magnitudes and correlation magnitude squares');
    plotyy(x, 10*log10(abs(samples)), x, abscorrvecsq);
    grid on

    figure
    subplot(2,2,1);
    plot(x, abs(samples), 'o-');
    subplot(2,2,3);
    plot(x, abscorrvec, 'g.-');
    subplot(2,2,[2 4]);
    %plotyy(x, abs(samples), x, abscorrvec);
    plotyy(x, 10*log10(abs(samples)), x, abscorrvec);
    grid on

  end

  data.corrvec = corrvec;
  data.abscorrvec = abscorrvec;
  data.abscorrvecsq = abscorrvecsq;
end

%----------------------------------------------------------------------------------------------------------------------------
function [stats data]= detectNextPacket(data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  pkt_start_point = -1;
  abscorrvec = data.abscorrvec;
  abscorrvecsq = data.abscorrvecsq;

  %samples = data.samples;
  %corrwin = opt.corrwin;
  corr_threshold = opt.corr_threshold;
  sq_corr_threshold = opt.sq_corr_threshold;
  peak_search_win_size = opt.peak_search_win_size;

  %rxgain = opt.rxgain;
  %nsyms = opt.nsyms_data;
  %scale = opt.scale;
  %rxgain = opt.rxgain;
  %atten = opt.atten;
  %corr_threshold = opt.corr_threshold;
  %pkt_period_samples = opt.pkt_period_samples;
  %pkt_length_samples = opt.pkt_length_samples;
  %ns_to_skip = opt.ns_to_skip;
  %ns_to_process = opt.ns_to_process;

  %next_search_window_start = find(abscorrvec >= corr_threshold, 1);

  %%%version 1: pkt length is known, so that pkt length can be skipped while locating the next corr peak
  %%%next_search_window_start = find(abscorrvec(data.pkt_start_point+opt.pkt_length_samples+1:end) >= corr_threshold, 1) + ...
  %%%		data.pkt_start_point+opt.pkt_length_samples;

  %%%version 2: pkt length is not assumed
  %%%next_search_window_start = find(abscorrvec(data.pkt_start_point+opt.peak_search_win_size+1:end) >= corr_threshold, 1) + ...
  %%%		data.pkt_start_point+opt.peak_search_win_size;


  %%%version 3: same as version 2 except on squared correlation values
  next_search_window_start = find(abscorrvecsq(data.pkt_start_point+opt.peak_search_win_size+1:end) >= sq_corr_threshold, 1) + ...
  		data.pkt_start_point+opt.peak_search_win_size;

  next_search_window_i = next_search_window_start:next_search_window_start+peak_search_win_size-1;
  next_search_window_c = abscorrvec(next_search_window_start:min(end,next_search_window_start+peak_search_win_size-1));
  [m i] = max(next_search_window_c)
  pkt_start_point = next_search_window_i(i)

  if (length(pkt_start_point) == 0)
    display('no more packets detected');
    pkt_start_point = -Inf;
    m = -1;
    i = -1;
  else
    display('maximum correlation value at any pkt start point:');
    max_corr_val = m
    stats.min_max_corr_val = min(stats.min_max_corr_val, m);
    stats.max_max_corr_val = max(stats.max_max_corr_val, m);

    %%%version 2
    %%%if (m < corr_threshold)

    %%%version 3
    if (m < sq_corr_threshold)
      m
      i
      error('max_corr_less_than_corr_threshold','packet detect point has correlation value smaller than threshold');
    end
  end

  stats.max_corr_val = m;
  stats.pkt_start_points(end+1,:) = pkt_start_point;
  data.pkt_start_point = pkt_start_point;

  %display('pkt start points:');
  %pkt_start_points = stats.pkt_start_points
  %pause
end

%----------------------------------------------------------------------------------------------------------------------------
function stats = updateStats(data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  if (data.frame_type == opt.ftype.data)
    stats.ber_vec_data(end+1) = data.ber;
    stats.crc_vec_data(end+1) = data.crcValid;

    %stats.ltf_sync_freq_domain = ltf_sync_freq_domain;
    stats.uu_ltf1_data(:,end+1) = data.uu_ltf1;
    stats.uu_ltf2_data(:,end+1) = data.uu_ltf2;
    stats.ch_data(:,end+1) = data.ch;
  elseif (data.frame_type == opt.ftype.ack)
    stats.ber_vec_ack(end+1) = data.ber;
    stats.crc_vec_ack(end+1) = data.crcValid;

    stats.uu_ltf1_ack(:,end+1) = data.uu_ltf1;
    stats.uu_ltf2_ack(:,end+1) = data.uu_ltf2;
    stats.ch_ack(:,end+1) = data.ch;
  elseif (data.frame_type == opt.ftype.unknown)
    stats.ber_vec_unknown(end+1) = data.ber;
    stats.crc_vec_unknown(end+1) = data.crcValid;

    stats.uu_ltf1_unknown(:,end+1) = data.uu_ltf1;
    stats.uu_ltf2_unknown(:,end+1) = data.uu_ltf2;
    stats.ch_unknown(:,end+1) = data.ch;
  end
end

%----------------------------------------------------------------------------------------------------------------------------
function stats = summarizeStats(stats, data, opt)
%----------------------------------------------------------------------------------------------------------------------------
%stats = 
%
%           idle_noise_power: [3x1 double]
%                  stf_power: [3x1 double]
%                  ltf_power: [3x1 double]
%                 data_power: [3x1 double]
%                  pkt_power: [3x1 double]
%                    snr_lin: [3x1 double]
%                     snr_db: [3x1 double]
%      coarse_cfo_angle_corr: [3x1 double]
%    coarse_cfo_freq_off_khz: [3x1 double]
%        fine_cfo_angle_corr: [3x1 double]
%      fine_cfo_freq_off_khz: [3x1 double]
%                        ber: [4x1 double]
%            n_bits_errors_i: [3x1 double]
%             net_snr_linear: [3x1 double]
%                 net_snr_db: [3x1 double]
%            n_bits_errors_q: []
%         ber_vs_ofdm_symbol: [3x250 double]
%         snr_per_subcarrier: [3x48 double]
%      snr_per_subcarrier_db: [3x48 double]
%          ber_vs_subcarrier: [3x48 double]
%               max_corr_val: 0.9658
%    n_packet_start_detected: 4
%               min_max_corr: 0.9534


  display('displaying statistics:');
  %stats

  inpl = length(stats.idle_noise_power)
  idle_noise_power_vector = stats.idle_noise_power(1:stats.n_packets_processed);
  mean_noise_power = mean(idle_noise_power_vector)
  std_noise_power = std(idle_noise_power_vector)

  stats.mean_noise_power = mean_noise_power;
  stats.std_noise_power = std_noise_power;

  snr_db_per_packet = stats.snr_db(1:stats.n_packets_processed);
  ber_per_packet = stats.ber(1:stats.n_packets_processed);

  if (stats.n_packets_processed > 0)
    display('Note: The following avg snr values are meaningful only if the noise vector is fairly constant');
    avg_snr_lin = mean(stats.snr_lin(stats.n_packets_processed))
    avg_snr_db = 10*log10(avg_snr_lin)
    avg_ber = mean(ber_per_packet)

    stats.avg_snr_lin = avg_snr_lin;
    stats.avg_snr_db = avg_snr_db;
    stats.avg_ber = avg_ber;
  else
    display('No packets detected/processed, no average statistics to display')

    stats.avg_snr_lin = -1;
    stats.avg_snr_db = -1;
    stats.avg_ber = -1;
  end

  pkt_start_points = stats.pkt_start_points

  if (opt.writeVars_startPnts)
    writeVars_startPnts(pkt_start_points);
  end

  n_data_packets = length(stats.ber_vec_data);
  n_ack_packets = length(stats.ber_vec_ack);
  n_unknown_packets = length(stats.ber_vec_unknown);
  
  n_crc_data = sum(stats.crc_vec_data);
  n_crc_ack = sum(stats.crc_vec_ack);

  ber_data_avg = mean(stats.ber_vec_data); ber_data_std = std(stats.ber_vec_data);
  ber_ack_avg = mean(stats.ber_vec_ack); ber_ack_std = std(stats.ber_vec_ack);

  display('=============================================================================================');
  display('Aggregate performance stats: data:');
  display(strcat('n_crc_data/n_data_packets: ', num2str(n_crc_data),'/',num2str(n_data_packets),...
     ' ber_data_avg/ber_data_std: ', num2str(ber_data_avg),'/',num2str(ber_data_std)));
  display(strcat('n_crc_ack/n_ack_packets: ', num2str(n_crc_ack),'/',num2str(n_ack_packets),...
     ' ber_ack_avg/ber_ack_std: ', num2str(ber_ack_avg),'/',num2str(ber_ack_std)));
  display(strcat('n_unknown_packets: ', num2str(n_unknown_packets)));
  display('=============================================================================================');





  %size(stats.uu_ltf1_data)
  %size(stats.uu_ltf2_data)
  %size(stats.ch_data)

  [avg_snr_data snr_v_data] = find_snr_from_uultfs(stats.uu_ltf1_data, stats.uu_ltf2_data, stats.ch_data);
  [avg_snr_ack snr_v_ack] = find_snr_from_uultfs(stats.uu_ltf1_ack, stats.uu_ltf2_ack, stats.ch_ack);
  avg_snr_data = avg_snr_data
  avg_snr_ack = avg_snr_ack

  %opt.GENERATE_ONE_TIME_PLOTS = true;

  if (opt.GENERATE_ONE_TIME_PLOTS)
    figure
    plot(1:length(snr_v_data), snr_v_data, 'b')
    hold on
    plot(1:length(snr_v_ack), snr_v_ack, 'r')
    ylim([0 50]);
    grid on
    title('avg snr of data (b) and ack (r) pkts (dB), dc in the middle');
  end

  if (opt.writeVars_cfos)
  writeVars_cfos(stats.coarse_cfo_freq_off_khz, stats.fine_cfo_freq_off_khz);
  end



  return
end

%----------------------------------------------------------------------------------------------------------------------------
function [avg_snr snr_v] = find_snr_from_uultfs(uu_ltf1_m, uu_ltf2_m, ch_m)
%----------------------------------------------------------------------------------------------------------------------------

  ltf_sync_freq_domain = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0, ...
			  1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1]';
  ltf_sync_freq_domain = [ zeros(6,1); ltf_sync_freq_domain; zeros(5,1)];

  %Channel will vary in phase everytime, so channel complex values are not consistent, leading to large std
  %ch_avg = mean(ch_m, 2);
  %ch_std_real = std(real(ch_m), 0, 2);
  %ch_std_imag = std(imag(ch_m), 0, 2);
  %[ch_avg abs(ch_avg) ch_std_real ch_std_imag]

  %Channel magnitudes have low variance since the channel is static in time, as expected
  %So we can work with our scheme of averaging snr across all packets, since channel is not varying in time
  chm_m = abs(ch_m);
  chm_avg = mean(chm_m, 2);
  chm_std = std(chm_m, 0, 2);
  %[chm_avg chm_std]
  chm_avg_nz = chm_avg(find(chm_avg > 0));
  min_chm_avg = min(chm_avg_nz)
  max_chm_std = max(chm_std)

  chm_avg_sq = chm_avg .* chm_avg;

  chm_sq_m = chm_m .* chm_m;
  chm_sq_avg = mean(chm_sq_m, 2);

  noise_m_1 = uu_ltf1_m - ch_m;
  noise_m_2 = uu_ltf2_m - ch_m;
  noise_m = [noise_m_1 noise_m_2];
  noise_avg = mean(noise_m, 2);

  %format long
  %display('a noise vector and average noise over a lot of samples:');
  %[noise_m_1(:,1) noise_avg]
  %pause
  %format

  %algo 1
  %%noise_var_r = (std(real(noise_m), 0, 2));
  %%noise_var_i = (std(imag(noise_m), 0, 2));
  %%noise_var_r = noise_var_r.*noise_var_r;
  %%noise_var_i = noise_var_i.*noise_var_i;
  %%display('noise_var_i and noise_var_q:');
  %%[noise_var_r noise_var_i]
  %%%noise_var = (noise_var_r + noise_var_i)/2;	%sigma^2/2
  %%cplx_noise_var = noise_var_r + noise_var_i;	%sigma^2
  %%%snr_lin = chm_avg_sq./noise_var;
  %%snr_lin = chm_sq_avg./cplx_noise_var;
  %%snr_db = 10*log10(snr_lin)
  %%pause

  %algo 2
  noise_power_avg = mean(noise_m .* conj(noise_m), 2);
  snr_lin = chm_sq_avg./noise_power_avg;
  snr_db = 10*log10(snr_lin);

  avg_snr = 10*log10(mean(chm_sq_avg)/mean(noise_power_avg));
  snr_v = snr_db;


end

%----------------------------------------------------------------------------------------------------------------------------
function stats = analyzeSinglePacket(data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  %n_p_d = stats.n_packets_processed
  [stats data]	= cleanupPacket(data, opt, stats);

  if (~data.cleanupDone)
    display('cleanupPacket failed');
    return;
  end
  %n_p_d = stats.n_packets_processed
  stats.n_packets_processed = stats.n_packets_processed + 1;
  %n_p_d = stats.n_packets_processed

  %%*********************************************************************************************************************************************
  %%%%%%%%% process signal field
  %%*********************************************************************************************************************************************

  nbpsc = 1;	%signal field is coded with bpsk
  nsyms = 1;	%signal field occupies one ofdm symbol
  [stats data rx_data_syms]  		= cleanupAndOfdmDemodSamples(data.sig_samples, nsyms, data, opt, stats);
  [stats data rx_data_bits]  		= demapPacket(rx_data_syms, nsyms, nbpsc, data, opt, stats);

  util_print_demapPacket_plcp(rx_data_syms, opt);

  %display('after demapping:');
  %rx_data_bits
  %pause

  [stats ber]   	     		= util_computeModulationBER(data, opt, stats);
  [stats data rx_data_bits_deint]       = deinterleave(data, opt, stats, rx_data_bits, nbpsc);

  %display('after deinterleave:');
  %rx_data_bits_deint
  %pause

  [stats data rx_data_bits_dec]         = decode(data, opt, stats, rx_data_bits_deint, opt.tblen_signal);

  %display('signal field after decode:');
  %rx_data_bits_dec
  %pause

  [stats data]				= parse_signal(data, opt, stats, rx_data_bits_dec);

  if (~data.sig_valid)
    return
  end


  %%*********************************************************************************************************************************************
  %%%%%% process data field
  %%*********************************************************************************************************************************************

  nbpsc = data.sig_modu;
  nsyms = data.sig_nsyms;
  coderate = data.sig_code;
  [stats data rx_data_syms]  = cleanupAndOfdmDemodSamples([data.sig_samples data.data_samples], data.sig_nsyms + 1, data, opt, stats);
  rx_data_syms(:,1)=[];
  rx_data_syms = rx_data_syms(:,1:nsyms);

  if (opt.printVars_equalize)
    util_print_equalize(rx_data_syms);
    if (opt.PAUSE_AFTER_EVERY_PACKET)
	    pause
    end
  end

  %display('size of rx_data_syms before demapping:');
  %size(rx_data_syms)

  %rx_data_syms = reshape(rx_data_syms, prod(size(rx_data_syms)), 1);
  [stats data rx_data_bits]  		= demapPacket(rx_data_syms, data.sig_nsyms, data.sig_modu, data, opt, stats);

  util_print_demapPacket_data(rx_data_bits, opt);

  %[stats ber]   	     		= util_computeModulationBER(data, opt, stats);
  [stats data rx_data_bits_deint]  	= deinterleave(data, opt, stats, rx_data_bits, nbpsc);

  if (opt.printVars_deinterleave)
	  util_print_deinterleave(rx_data_bits_deint);
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
		  pause
	  end
  end

  %display('after deinterleave:');
  %rx_data_bits_deint
  %pause

  rx_data_bits_deint = reshape(rx_data_bits_deint, prod(size(rx_data_bits_deint)), 1);
  [stats data rx_data_bits_depunct]     = depuncture(data, opt, stats, rx_data_bits_deint, coderate);

  %display('after depuncture');
  %rx_data_bits_depunct
  %pause

  %decode the actual data length portion
  data_and_tail_length_bits = 16 + data.sig_payload_length * 8 + 6;	%first 16 for service, last 6 for tail
  actual_data_portion_with_tail = rx_data_bits_depunct(1:(data_and_tail_length_bits * 2));	%since it's a half rate code

  [stats data rx_data_bits_dec]         = decode(data, opt, stats, rx_data_bits_depunct, opt.tblen_data);

  %display('data field after decode (including service field):');
  %rx_data_bits_dec
  %pause

  if (opt.printVars_decodedBits)
	  util_print_decode(rx_data_bits_dec, data.sig_ndbps, opt.n_decoded_symbols_per_ofdm_symbol);
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
		  pause
	  end
  end


  %display('scrambled service field:');
  %rx_data_bits_dec(1:16)
  %pause

  %remove tail
  %rx_data_bits_dec = rx_data_bits_dec(1:end-6);

  [rx_data_bits_descr]			= descramble(rx_data_bits_dec);

  if (opt.printVars_descrambledBits)
	  util_print_descramble(rx_data_bits_descr, data.sig_ndbps);
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
		  pause
	  end
  end

  %display('data field after decode and descramble (including service field) arranged as bytes:');
  rx_data_bytes = reshape(rx_data_bits_descr, 8, length(rx_data_bits_descr)/8);

  %retain only upto the data portion, including service field but discarding tail and pad
  rx_data_bits_descr = rx_data_bits_descr(1:(16+data.sig_payload_length * 8));
  rx_data_bytes = reshape(rx_data_bits_descr, 8, data.sig_payload_length + 2);
  size_rx_data_bytes = size(rx_data_bytes);

  %pause

  %[parsed_data data]			= parse_payload(rx_data_bytes, data);
  [data.parsed_data data.frame_type data.ber data.crcValid] = parse_payload(rx_data_bytes);

  %display('data bits arranged as bytes (excluding service)');
  %rx_data_bytes(:,3:end)

  %size_parsed_data = size(parsed_data)
  display('hex data bytes');
  %[(1:data.sig_payload_length)' parsed_data]
  %parsed_data
  util_printHexOctets(data.parsed_data);

  %%*********************************************************************************************************************************************
  %% display plcp intermediaries/results
  %%*********************************************************************************************************************************************


  display('------------------------------------------------------------');
  display('parse data results: ');
  display(strcat('frame_type (0: data, 1: ack, 2: unknown):', num2str(data.frame_type), ...
    ' ber:', num2str(data.ber), ' crcValid:', num2str(data.crcValid)));
  display('------------------------------------------------------------');


  %%*********************************************************************************************************************************************
  %% display data intermediaries/results
  %%*********************************************************************************************************************************************

  if (opt.printVars_data_syms)
	  util_print_data_syms(...
	    opt, ...
	    data,...
	    rx_data_syms, ...
	    rx_data_bits, ...
	    rx_data_bits_deint,...
	    rx_data_bits_dec...
	    );
  end

  %%*********************************************************************************************************************************************
  %%*********************************************************************************************************************************************
  %function stats = updateStats(data, stats)
  stats = updateStats(data, opt, stats);


end



%----------------------------------------------------------------------------------------------------------------------------
function [stats data] = cleanupPacket(data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  data.cleanupDone = 0;

  noise_win_len = opt.noise_win_len;
  noise_fft_size = opt.noise_fft_size;
  stf_len = opt.stf_len;
  ltf_len = opt.ltf_len;
  sig_len = opt.sig_len;
  stf_shift_len = opt.stf_shift_len;
  ltf_shift_len = opt.ltf_shift_len;
  sample_duration_sec = opt.sample_duration_sec;

  sym_len_s  = opt.sym_len_s ;
  cp_len_s  = opt.cp_len_s ;
  fft_size  = opt.fft_size ;
  cp_skip  = opt.cp_skip ;


  rx_data_syms = [];
  data.rx_data_syms = rx_data_syms; 

  if (nargin < 3)
    opt.COARSE_CFO_CORRECTION = true;
    opt.FINE_CFO_CORRECTION = true;
    opt.PILOT_PHASE_TRACKING = true;
    opt.PILOT_SAMPLING_DELAY_CORRECTION = true;		%this is really referring to sampling delay 
    							%introduced due to sampling frequency offset
    opt.GENERATE_ONE_TIME_PLOTS = true;
    opt.GENERATE_PER_PACKET_PLOTS = false;
  end

  %verify availability of enough noise samples for the noise window to be analyzed
  %if (data.pkt_start_point < 1+noise_win_len)
  %  display('not enough pre-noise samples for this packet')
  %  data.pkt_start_point = -2;
  %  return
  %end

  %verify validity of pkt detect point - corr value must drop on either side (it should be a peak)
  %%%data.pkt_start_point-10
  %%%data.pkt_start_point-1
  left_10_c = data.abscorrvec(data.pkt_start_point-10:data.pkt_start_point-1);
  right_10_c = data.abscorrvec(data.pkt_start_point+1:data.pkt_start_point+10);
  peak_c = data.abscorrvec(data.pkt_start_point);

  if ([left_10_c right_10_c] > peak_c)
    display('packet correlation peak not well-detected')
    return
  end

  %verify we have the whole packet in sample stream
  %if (length(data.samples) < data.pkt_start_point + opt.pkt_length_samples - 1)
  if (length(data.samples) < data.pkt_start_point + opt.ns_ofdm_phy_preamble_signal - 1)
    %display('sample stream does not contain the entire packet');
    display('sample stream does not contain even enough samples for preamble and signal field');
    return
  end

  if (isfield(opt,'pkt_length_samples'))
    pkt_length_samples = opt.pkt_length_samples;
  else
    pkt_length_samples = opt.max_pkt_length_samples;
  end

  if (length(data.samples) < data.pkt_start_point + pkt_length_samples - 1)
    %display('sample stream does not contain the entire packet');
    display('sample stream does not contain enough samples for processing');
    return
  end

  %pkt_samples = data.samples(data.pkt_start_point:data.pkt_start_point+opt.pkt_length_samples-1);
  pkt_samples = data.samples(data.pkt_start_point:data.pkt_start_point+pkt_length_samples-1);
  stf_samples = pkt_samples(1:stf_len);
  ltf_samples = pkt_samples(stf_len+1:stf_len+ltf_len);
  sig_samples = pkt_samples((stf_len+ltf_len+1):(stf_len+ltf_len+sig_len));
  data_samples = pkt_samples(stf_len+ltf_len+sig_len+1:end);

  %verify availability of enough noise samples for the noise window to be analyzed
  if (data.pkt_start_point < 1+noise_win_len)
    display('not enough pre-noise samples for this packet, using as many as available')
  %  data.pkt_start_point = -2;
  %  return
    noise_samples = data.samples(1:data.pkt_start_point-1);
  else
    noise_samples = data.samples(data.pkt_start_point-noise_win_len:data.pkt_start_point-1);
  end

  %display('power and snr values before any processing:');
  %display('(these are computed based on silent period noise power and packet samples in time domain)');

  idle_noise_power = power(noise_samples);
  stf_power = power(stf_samples);
  ltf_power = power(ltf_samples);
  sig_power = power(sig_samples);
  data_power = power(data_samples);
  pkt_power = power(pkt_samples);

  snr_lin = stf_power/idle_noise_power;
  snr_db = 10*log10(snr_lin);

  stats.idle_noise_power(end+1,:) = idle_noise_power;
  stats.stf_power(end+1,:) = stf_power;
  stats.ltf_power(end+1,:) = ltf_power;
  stats.sig_power(end+1,:) = sig_power;
  stats.data_power(end+1,:) = data_power;
  stats.pkt_power(end+1,:) = pkt_power;

  stats.snr_lin(end+1,:) = snr_lin;
  stats.snr_db(end+1,:) = snr_db;



  %------ stf based cfo estimation and correction ------
  if (opt.COARSE_CFO_CORRECTION)
    display('stf based cfo estimation and correction');

    %a more accurate estimate but possibly missing multiples of 2*pi
    angle_corr = angle(data.corrvec(data.pkt_start_point));		%radians
    %freq_off_khz = (angle_corr/(pi*stf_len*sample_duration_sec))/1000
    freq_off_khz = (angle_corr/(2*pi*stf_shift_len*sample_duration_sec))/1000;

    %for detecting multiples of 2*pi in case the offset is really high
    stf_period = 16;
    stf_9th_period = stf_samples(8*stf_period+1:9*stf_period);
    stf_10th_period = stf_samples(9*stf_period+1:end);
    angle_corr_short = angle(sum(conj(stf_9th_period) .* stf_10th_period));
    angle_corr_pred_from_short = angle_corr_short * 5;
    %freq_off_khz = (angle_corr/(pi*stf_len*sample_duration_sec))/1000
    freq_off_khz_short = (angle_corr_short/(2*pi*stf_period*sample_duration_sec))/1000;

    if (abs(angle_corr_pred_from_short - angle_corr) > pi) 
      display('CFO detection algorithm maybe be missing multiples of pi.');
      display('Inspect the values above and press any key to proceed.');
      pause
    end

    stats.coarse_cfo_angle_corr(end+1,:) = angle_corr;
    stats.coarse_cfo_freq_off_khz(end+1,:) = freq_off_khz;
    coarse_cfo_freq_off_khz = freq_off_khz;

    %version 1: where stf starts at time t = 0
    %%freq_off_hz = freq_off_khz * 1000;
    %%%t_secs = [0:(opt.pkt_length_samples-1)]*sample_duration_sec;
    %%t_secs = [0:(pkt_length_samples-1)]*sample_duration_sec;
    %%cfo_corr = exp(-2*pi*i*freq_off_hz*t_secs);

    %%%version 2: where ltf starts at time t = 0; this matches how we do it on TI
    %%freq_off_hz = freq_off_khz * 1000;
    %%%t_secs = [0:(opt.pkt_length_samples-1)]*sample_duration_sec;
    %%t_secs = [0:(pkt_length_samples-1)]*sample_duration_sec - 160 * sample_duration_sec;
    %%cfo_corr = exp(-2*pi*i*freq_off_hz*t_secs);

    %version 3: where each data symbol is also modeled as starting at time t = 0; this matches how we do it on TI
    %ltf 160 samples are in series, as also on TI.
    freq_off_hz = freq_off_khz * 1000;
    t_secs = [0:(stf_len+ltf_len-1)]*sample_duration_sec - 160 * sample_duration_sec;			%correction time-coeffs for stf, ltf parts
    t_secs = [t_secs mod([0:((pkt_length_samples - stf_len - ltf_len)-1)],80)*sample_duration_sec];	%correction time-coeffs for data symbols appended
    cfo_corr = exp(-2*pi*i*freq_off_hz*t_secs);


    %%%%%%%%%%%%%%%%%%%%%%%
    ltf_samples = pkt_samples(stf_len+1:stf_len+ltf_len);
    ltf1_t = ltf_samples(33:96);
    ltf2_t = ltf_samples(97:160);
    display('ltfs in time domain before any cfo');
    if (opt.printVars_chEsts)
	  display('the two ltfs: ')
	  [ [1:64]' fix(opt.ti_factor * [ ltf1_t.' ltf2_t.'])]
	  %pause
    end
    %%%%%%%%%%%%%%%%%%%%%%%

    %cfo correction
    pkt_samples = pkt_samples .* cfo_corr;

    %cfo corrected ltf and data portions
    ltf_samples = pkt_samples(stf_len+1:stf_len+ltf_len);
    sig_samples = pkt_samples(stf_len+ltf_len+1:stf_len+ltf_len+sig_len);
    data_samples = pkt_samples(stf_len+ltf_len+sig_len+1:end);
  else
    display('stf based cfo estimation and correction is disabled');
  end


  %------ ltf based cfo estimation and correction -------
  if (opt.FINE_CFO_CORRECTION)
    display('ltf based cfo estimation and correction');
    ltf1_s = ltf_samples(16+1+cp_skip:16+cp_skip+fft_size);
    ltf2_s = ltf_samples(16+1+cp_skip+fft_size:16+cp_skip+2*fft_size);

    angle_corr = angle(sum(conj(ltf1_s) .* ltf2_s));
    freq_off_khz = (angle_corr/(2*pi*ltf_shift_len*sample_duration_sec))/1000;
    %pause

    stats.fine_cfo_angle_corr(end+1,:) = angle_corr;
    stats.fine_cfo_freq_off_khz(end+1,:) = freq_off_khz;
    fine_cfo_freq_off_khz = freq_off_khz;

    net_cfo_freq_off_khz = coarse_cfo_freq_off_khz + fine_cfo_freq_off_khz
    pause

    %version 1, where stf starts at t = 0
    %%freq_off_hz = freq_off_khz * 1000;
    %%%t_secs = [0:(opt.pkt_length_samples-1)]*sample_duration_sec;
    %%t_secs = [0:(pkt_length_samples-1)]*sample_duration_sec;
    %%cfo_corr = exp(-2*pi*i*freq_off_hz*t_secs);

    %%%version 2: where ltf starts at time t = 0; this matches how we do it on TI
    %%freq_off_hz = freq_off_khz * 1000;
    %%%t_secs = [0:(opt.pkt_length_samples-1)]*sample_duration_sec;
    %%t_secs = [0:(pkt_length_samples-1)]*sample_duration_sec - 160 * sample_duration_sec;
    %%cfo_corr = exp(-2*pi*i*freq_off_hz*t_secs);

    %version 3: where each data symbol is also modeled as starting at time t = 0; this matches how we do it on TI
    %ltf 160 samples are in series, as also on TI.
    freq_off_hz = freq_off_khz * 1000;
    t_secs = [0:(stf_len+ltf_len-1)]*sample_duration_sec - 160 * sample_duration_sec;			%correction time-coeffs for stf, ltf parts
    t_secs = [t_secs mod([0:((pkt_length_samples - stf_len - ltf_len)-1)],80)*sample_duration_sec];	%correction time-coeffs for data symbols appended
    cfo_corr = exp(-2*pi*i*freq_off_hz*t_secs);


    %cfo correction
    pkt_samples = pkt_samples .* cfo_corr;

    %cfo corrected ltf and data portions
    ltf_samples = pkt_samples(stf_len+1:stf_len+ltf_len);
    sig_samples = pkt_samples(stf_len+ltf_len+1:stf_len+ltf_len+sig_len);
    data_samples = pkt_samples(stf_len+ltf_len+sig_len+1:end);

    %%%%%%%%%%%%%%%%%%%%%%%
    ltf_samples = pkt_samples(stf_len+1:stf_len+ltf_len);
    ltf1_t = ltf_samples(33:96);
    ltf2_t = ltf_samples(97:160);
    display('ltfs in time domain after all cfo correction');
    if (opt.printVars_chEsts)
	  display('the two ltfs: ')
	  [ [1:64]' fix(opt.ti_factor_after_cfo * [ ltf1_t.' ltf2_t.'])]
	  %pause
    end
    %%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%
    plcp_samples = sig_samples;
    display('plcp signal field in time domain after all cfo correction');
    if (opt.printVars_cfoCorrectedPlcp)
	  [ [1:80]' fix(opt.ti_factor_after_cfo * plcp_samples.')]
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
	    pause
	  end
    end
    %%%%%%%%%%%%%%%%%%%%%%%


  else
    display('ltf based cfo estimation and correcion is disabled')
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % estimating noise PSD after rx decimation
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Note: the following samples still suffer cfo,
  %thus, this PSD is not accurate.

  %%%%%n_noise_symbols = length(noise_samples)/noise_fft_size;
  %%%%%noise_symbols = reshape(noise_samples,noise_fft_size,n_noise_symbols);
  %%%%%%since noise is not white anymore due to frequency-selective filters, we 
  %%%%%%want to have the true PSD computed using fft
  %%%%%size(noise_symbols)
  %%%%%noise_syms_f = fftshift(fft(noise_symbols));
  %%%%%size(noise_syms_f)
  %%%%%noise_syms_f_power = noise_syms_f .* conj(noise_syms_f);
  %%%%%format long;
  %%%%%noise_syms_f_power_av = sum(noise_syms_f_power,2)/n_noise_symbols
  %%%%%pause

  %------- channel estimation and correction ----
  ltf_sync_freq_domain = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0, ...
			  1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1]';
  ltf_sync_freq_domain = [ zeros(6,1); ltf_sync_freq_domain; zeros(5,1)];

  %ltf_sync_time_oneperiod = (ifft(ifftshift(ltf_sync_freq_domain)))

%  window_func = [0.5 ones(1,159) 0.5]';
%  %add cp and double the length, and multiply by the window function
%  ltf_sync_total = window_func.*[ltf_sync_time_oneperiod( (33):64); 
%				  ltf_sync_time_oneperiod; 
%				  ltf_sync_time_oneperiod;
%				  ltf_sync_time_oneperiod(1)]
  ltf1_s = ltf_samples(16+1+cp_skip:16+cp_skip+fft_size);
  ltf2_s = ltf_samples(16+1+cp_skip+fft_size:16+cp_skip+2*fft_size);
  ltf1_f = fftshift(fft(ltf1_s));
  ltf2_f = fftshift(fft(ltf2_s));

  if (opt.printVars_chEsts)
	  display('the two ltfs in frequency domain: ')
	  [ [1:64]' fix(opt.ti_factor * [ ltf1_f.' ltf2_f.'])]
	  pause
  end

  %%%%%%%%%%%%% begin algo 1 %%%%%%%%%%%%%%%
  %complex channel gain
  ltf_f_av = (ltf1_f+ltf2_f)/2;			%NOTE: This may be a bad idea in the presence of sampling frequency offset.
  						%SFO should firt be corrected, then the ltf symbols should be averaged.

  %display('ltf1, ltf2, ltf_average:');
  %[ltf1_f.' ltf2_f.' ltf_f_av.']

  ch = (ltf_f_av.') .* ltf_sync_freq_domain;		%multiplication is used instead of division because
  						%the reference ltf symbol sequence (freq domain) contains
						%zeroes. since the loaded symbols have magnitude 1, multiplication
						%is equivalent to division for rest of the subcarriers.
  %%%%%%%%%%%%% finish algo 1 %%%%%%%%%%%%%%%

  %add to statistics
  stats.all_ltf1_64(end+1:end+64) = ltf1_f;
  stats.all_ltf2_64(end+1:end+64) = ltf2_f;
  stats.all_ltf_av_64(end+1:end+64) = ltf_f_av;
  stats.all_channel_64(end+1:end+64) = ch;

  if (opt.printVars_chEsts)
	  [ [1:64]' fix(opt.ti_factor * ch)]
	  nsubc = 64
	  psubc_idx = (nsubc/2)+[(1+[-21 -7 7 21])];					%regular order (dc in middle)
	  dsubc_idx = (nsubc/2)+[(1+[-26:-22 -20:-8 -6:-1]) (1+[1:6 8:20 22:26])];	%regular order (dc in middle)
	  ch_data = [[1:48]' fix(opt.ti_factor * ch(dsubc_idx))]
	  ch_pilot = [[1:4]' fix(opt.ti_factor * ch(psubc_idx))]
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
	  pause
	  end
  end

  %%%%%%%%%%%%% begin algo 2 %%%%%%%%%%%%%%%
  %scalar magnitude only
  %ltf_f_av = abs(ltf1_f) + abs(ltf2_f);
  %ch = (ltf_f_av)/2;
  %%%%%%%%%%%%% finish algo 2 %%%%%%%%%%%%%%%
  
  uu_ltf1 = (ltf1_f.') .* ltf_sync_freq_domain;		%multiplication is used instead of division because
  uu_ltf2 = (ltf2_f.') .* ltf_sync_freq_domain;		%multiplication is used instead of division because

  data.uu_ltf1 = uu_ltf1;
  data.uu_ltf2 = uu_ltf2;
  %data.ltf_sync_freq_domain = ltf_sync_freq_domain;
  data.ch = ch;

  %[uu_ltf1 uu_ltf2 abs(uu_ltf1) abs(uu_ltf2) angle(uu_ltf1) angle(uu_ltf2)]
  %pause

  chi = 1./ch;
  ch_abs_db = 10*log10(abs(ch));

  data.sig_samples = sig_samples;
  data.data_samples = data_samples;
  data.chi = chi;

  display('channel gains, channel gain magnitudes (dB):');
  [ch ch_abs_db]

  if (opt.GENERATE_PER_PACKET_PLOTS)
    figure
    hold on
    plot(1:64, angle(uu_ltf1),'b-.');
    plot(1:64, angle(uu_ltf2),'r-.');
  end
  %pause

  data.cleanupDone = 1;

  if (opt.GENERATE_PER_PACKET_PLOTS)
    figure

    subplot(6,1,1)
    hold on
    plot(1:64, abs(ltf1_f),'g-.');
    plot(1:64, abs(ltf2_f),'b-.');
    plot(1:64, abs(ltf_f_av),'r-.');
    title('|.| of ltf symbols in frequency domain after cfo correction, red: mean')
    grid on
    %title('|.|')

    subplot(6,1,2)
    hold on
    plot(1:64, real(ltf1_f),'g-.');
    plot(1:64, real(ltf2_f),'b-.');
    plot(1:64, real(ltf_f_av),'r-.');
    title('real(.)')
    grid on

    subplot(6,1,3)
    hold on
    plot(1:64, imag(ltf1_f),'g-.');
    plot(1:64, imag(ltf2_f),'b-.');
    plot(1:64, imag(ltf_f_av),'r-.');
    title('imag(.)')
    grid on

    subplot(6,1,4)
    plot(1:64, abs(ch),'g-.');
    title('|.| of channel, linear');
    grid on

    subplot(6,1,4)
    plot(1:64, abs(ch),'g-.');
    title('|.| of channel, linear');
    grid on

    subplot(6,1,5)
    plot(1:64, ch_abs_db,'b-.');
    title('|.| of channel, dB');
    grid on

    subplot(6,1,6)
    plot(1:64, angle(ch),'b-.');
    title('angle(.) of channel');
    grid on
  end
end

%----------------------------------------------------------------------------------------------------------------------------
function [stats data rx_data_syms] = cleanupAndOfdmDemodSamples(samples, nsyms, data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  %------- data demodulation ---------
  data_samples = samples(1:(opt.sym_len_s*nsyms));
  chi = data.chi;

  noise_win_len = opt.noise_win_len;
  noise_fft_size = opt.noise_fft_size;
  stf_len = opt.stf_len;
  ltf_len = opt.ltf_len;
  sig_len = opt.sig_len;
  stf_shift_len = opt.stf_shift_len;
  ltf_shift_len = opt.ltf_shift_len;
  sample_duration_sec = opt.sample_duration_sec;

  sym_len_s  = opt.sym_len_s ;
  cp_len_s  = opt.cp_len_s ;
  fft_size  = opt.fft_size ;
  cp_skip  = opt.cp_skip ;

  n_syms = length(data_samples)/sym_len_s;
  %size(data_samples)
  ofdm_syms_t = reshape(data_samples, sym_len_s, n_syms);
  %size(ofdm_syms_t)
  %pause
  %data_samples(1:160)
  %ofdm_syms_t(:,[1 2])

  %for debug
  data.ofdm_syms_t_with_cp = ofdm_syms_t;

  %remove cp
  ofdm_syms_t = ofdm_syms_t(1+cp_skip:cp_skip+fft_size,:);

  %for debug
  data.ofdm_syms_t_no_cp = ofdm_syms_t;

  %ofdm demod
  ofdm_syms_f = fftshift(fft(ofdm_syms_t),1);	%fftshift along rows (each column is fftshifted)

  tx_pilot_syms = data.sig_and_data_tx_pilot_syms(:,1:nsyms);
  %%%%%tx_data1_syms = data.tx_data_syms(d1subc_idx, :);


  %%%%%%%%%%%%%%%%%%%%%%%
  nsubc = 64;
  psubc_idx = (nsubc/2)+[(1+[-21 -7 7 21])];					%regular order (dc in middle)
  dsubc_idx = (nsubc/2)+[(1+[-26:-22 -20:-8 -6:-1]) (1+[1:6 8:20 22:26])];	%regular order (dc in middle)
    display('plcp signal field in frequency domain before equalization');
    if (opt.printVars_ofdmDemodPlcp)
	    display('plcp data subcarriers:');
	  [ [1:48]' fix(opt.ti_factor_after_cfo * ofdm_syms_f(dsubc_idx))]
	    display('plcp pilot subcarriers:');
	  [ [1:4]' fix(opt.ti_factor_after_cfo * (ofdm_syms_f(psubc_idx) .* conj(tx_pilot_syms)))]
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
	    pause
	  end
    end
  %%%%%%%%%%%%%%%%%%%%%%%


  %------ data and pilot subcarrier indices ------
  nsubc = 64; 									%number of subcarriers
  psubc_idx = (nsubc/2)+[(1+[-21 -7 7 21])];					%regular order (dc in middle)
  %pause

  d1subc_idx = (nsubc/2)+[(1+[-32 -1 1 31])];					%regular order (dc in middle)
  %-------------------------------------------------


  rx_pilot_syms_before_chi = ofdm_syms_f(psubc_idx, :);
  rx_data_syms_before_chi = ofdm_syms_f(dsubc_idx, :);

  %for debug
  uu_pilot_syms_before_chi = rx_pilot_syms_before_chi .* conj(tx_pilot_syms);	%tx pilot symbols are all +-1, so this gives 
  data.uu_pilot_syms_before_chi = uu_pilot_syms_before_chi;
  data.rx_data_syms_before_chi = rx_data_syms_before_chi;

  %------- channel correction -------------
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % channel correction (equalization)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %equalize
  %size(diag(chi))
  %size(ofdm_syms_f)
  ofdm_syms_f = diag(chi) * ofdm_syms_f;
  %------ done channel correction -------------



  %------ separate data and pilot tones -------
  rx_pilot_syms = ofdm_syms_f(psubc_idx, :);

  %for debug
  data.rx_pilot_syms = rx_pilot_syms;

  %size(rx_pilot_syms)
  %size(tx_pilot_syms)
  %pause

  uu_pilot_syms = rx_pilot_syms .* conj(tx_pilot_syms);				%tx pilot symbols are all +-1, so this gives 
  										%the rx symbol corresponding to tx symbol 1


  %for debug
  data.uu_pilot_syms_after_chi = uu_pilot_syms;

  dsubc_idx = (nsubc/2)+[(1+[-26:-22 -20:-8 -6:-1]) (1+[1:6 8:20 22:26])];	%regular order (dc in middle)


  
  if (opt.PILOT_PHASE_TRACKING)
    display('pilot based phase tracking and compensation');
    %size(uu_pilot_syms)
    uu_pilot_syms_avg = sum(uu_pilot_syms)/4;
    uu_pilot_syms_avg_ph = angle(uu_pilot_syms_avg);
    phase_correction = exp(-i*uu_pilot_syms_avg_ph);
    %size(ofdm_syms_f)
    %size(phase_correction)
    %pause

    %for debug
    data.phase_correction_vector = phase_correction;
    
    ofdm_syms_f = ofdm_syms_f * diag(phase_correction);

    %resample pilots after this correction, so the further stages can use this stage's correction
    rx_pilot_syms = ofdm_syms_f(psubc_idx, :);
    uu_pilot_syms = rx_pilot_syms .* tx_pilot_syms;	%tx pilot symbols are all +-1, so this gives 
  							%the rx symbol corresponding to tx symbol 1
  else
    display('pilot based phase tracking and compensation is disabled');
  end

  %%%%%%%%%%%%%%%%%%%%%%%
  %  display('plcp signal field in frequency domain after equalization and pilot phase correction');
  %  if (opt.printVars_ofdmEqualizedPlcp)
  %          display('plcp data subcarriers:');
  %          size(ofdm_syms_f)
  %          size(dsubc_idx)
  %        [ [1:48]' fix(opt.ti_factor_after_cfo * ofdm_syms_f(dsubc_idx, 1))]
  %          display('plcp pilot subcarriers:');
  %          size(uu_pilot_syms)
  %        [ [1:4]' fix(opt.ti_factor_after_cfo * uu_pilot_syms(:,1))]
  %        if (opt.PAUSE_AFTER_EVERY_PACKET)
  %          pause
  %        end
  %  end
  %%%%%%%%%%%%%%%%%%%%%%%

   
  if (opt.PILOT_SAMPLING_DELAY_CORRECTION)
    display('pilot based sampling delay (due to sampling freq offset) correction');

    % Algorithm:
    % y=[y-21; y-7; y7; y21;]
    % x=[-21 -7 7 21]
    % y = px => y = xp, p is a scalar to be determined: that's the linear model of phase offset
    % then, p_opt (MSE) = pinv(x).y, where pinv(x) = (x^T x)^-1 x^T, so that with dc considered 
    % to be subcarrier index k = 0, p = (1/980)*(-21.y(-21) + -7.y(-7) + 7.y(7) + 21.y(21)], where
    % y's reflect phases (mod 2*pi, so that they all like in [0,2*pi) and averaging is valid)
    % of the respective subcarriers. Phase correction coefficients can then be generated according 
    % to exp(-jkp).

    %%%%% begin algorithm 1 %%%%%%%%
    %p_vec = (1/980)*([-21 -7 7 21] * mod(angle(uu_pilot_syms),2*pi));
    p_vec = (1/980)*([-21 -7 7 21] * angle(uu_pilot_syms));
    %%%%% finish algorithm 1 %%%%%%%%

    %%%%%%%%%% begin algorithm 2 %%%%%%%%
    %%%%%circular_angles = angle(uu_pilot_syms);

    %%%%%%figure
    %%%%%%hold on
    %%%%%%%plot(angle(uu_pilot_syms(1,:)),'r.-')
    %%%%%%plot(angle(uu_pilot_syms(2,:)),'g.-')
    %%%%%%plot(angle(uu_pilot_syms(3,:)),'b.-')
    %%%%%%%plot(angle(uu_pilot_syms(4,:)),'k.-')
    %%%%%%title('pilot tone 1-4, rgbk angle(.), before sampling offset correction, after common phase removal')
    %%%%%%pause

    %%%%%a1=circular_angles(1,:); a2=circular_angles(2,:); a3=circular_angles(3,:); a4=circular_angles(4,:);
    %%%%%a1 = mod(a1,2*pi*sign(a2));			%NOTE: This includes the ASSUMPTION that the linear angle
    %%%%%						%at the outer subpilot will not exceed 2*pi in magnitude,
    %%%%%    					%which is saying that the maximum sampling "phase" offset
    %%%%%    					%at that subcarrier will not be more than 2*pi, or maximum
    %%%%%    					%sampling delay will not be more than T such 2*pi*(312.5kHz*21)*T = 2*pi,
    %%%%%    					%or, T_max = 1(312.5*21) ms = 152ns. This is true since sample
    %%%%%    					%duration is 50ns. (What happens if sampling delay has indeed 
    %%%%%    					%accummulated to more than 50ns and we have jumped a sample?)
    %%%%%    					%(Also, the above is true only if other phase contributions, like
    %%%%%    					%that from CFO, multipath channel and system response, have 
    %%%%%    					%already been corrected, not when they have been pushed to 
    %%%%%    					%this stage).

    %%%%%a4 = mod(a4,2*pi*sign(a3));
    %%%%%prod_sign = sign(a2).*sign(a3)		%must be -1
    %%%%%linear_angles = [a1; a2; a3; a4];
    %%%%%circular_angles(:,[1:20])
    %%%%%linear_angles(:,[1:10])
    %%%%%pause

    %%%%%p_vec = (1/980)*([-21 -7 7 21] * (linear_angles));
    %%%%%%%%%% finish algorithm 2 %%%%%%%%
    %%%%%%%%% this one seems buggy %%%%%

    p_corr_terms = exp(-i * diag([-32:31]) * ones(64,size(ofdm_syms_f,2)) * diag(p_vec));
    ofdm_syms_f = ofdm_syms_f .* p_corr_terms;

    rx_pilot_syms = ofdm_syms_f(psubc_idx, :);
    uu_pilot_syms = rx_pilot_syms .* tx_pilot_syms;	%tx pilot symbols are all +-1, so this gives 
  							%the rx symbol corresponding to tx symbol 1


  else
    display('pilot based sampling delay (due to sampling freq offset) correction is disabled');
  end

  rx_data_syms = ofdm_syms_f(dsubc_idx, :);
  %data.rx_data_syms = rx_data_syms; 

  %%%%rx_data1_syms = ofdm_syms_f(d1subc_idx, :);
  %%%%uu_data1_syms = rx_data1_syms .* conj(tx_pilot_syms);

  %display('rx_pilot_syms, tx_pilot_syms, uu_pilot_syms:');
  %[rx_pilot_syms(:,[1:5]) tx_pilot_syms(:,[1:5]) uu_pilot_syms(:,[1:5])]

  if (opt.GENERATE_PER_PACKET_PLOTS)
    figure
    subplot(3,1,1)
    hold on
    plot(abs(uu_pilot_syms(1,:)),'r.-')
    plot(abs(uu_pilot_syms(2,:)),'g.-')
    plot(abs(uu_pilot_syms(3,:)),'b.-')
    plot(abs(uu_pilot_syms(4,:)),'k.-')
    title('pilot tone 1-4, rgbk, |.|')

    subplot(3,1,2)
    hold on
    plot(10*log10(abs(uu_pilot_syms(1,:))),'r.-')
    plot(10*log10(abs(uu_pilot_syms(2,:))),'g.-')
    plot(10*log10(abs(uu_pilot_syms(3,:))),'b.-')
    plot(10*log10(abs(uu_pilot_syms(4,:))),'k.-')
    title('pilot tone 1-4, rgbk, |.| dB')

    subplot(3,1,3)
    hold on
    plot(angle(uu_pilot_syms(1,:)),'r.-')
    plot(angle(uu_pilot_syms(2,:)),'g.-')
    plot(angle(uu_pilot_syms(3,:)),'b.-')
    plot(angle(uu_pilot_syms(4,:)),'k.-')
    title('pilot tone 1-4, rgbk angle(.)')

    %subplot(4,1,3)
    %plot(abs(uu_pilot_syms(2,:)))
    %title('pilot tone 2, |.|')

    %subplot(4,1,4)
    %plot(angle(uu_pilot_syms(2,:)))
    %title('pilot tone 2, angle(.)')
  end

  %pause

  %display('first three ofdm symbols in frequency domain (each col is a symbol):');
  %ofdm_syms_f(:,1:3)

end

%----------------------------------------------------------------------------------------------------------------------------
function util_print_equalize(rx_data_syms)
%----------------------------------------------------------------------------------------------------------------------------
  fprintf(1,'\nbegin util_print_equalize');

  fprintf(1,'\nequalized constellation points of symbols\n');
  size(rx_data_syms)
  
  nsyms = size(rx_data_syms, 2)

  factor = 60/0.93;
  rx_data_syms = fix(rx_data_syms * factor);

  for i = 1:nsyms
	  i = i
          symi_eq_pnts = [(1:48)' rx_data_syms(:, i)]
          pause
  end
  pause


  fprintf(1,'end util_print_equalize\n');
end



%----------------------------------------------------------------------------------------------------------------------------
function [stats data rx_data_bits] = demapPacket_old(rx_data_syms, data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------

  %rx_data_syms = data.rx_data_syms;

  if (prod(size(rx_data_syms)) == 0)
    return;
  end
  %stats.n_packets_processed = stats.n_packets_processed + 1;

  util_plotConstellation(rx_data_syms, opt);

  %hard-demap symbols to bits according to bpsk
  rx_data_syms_i = real(rx_data_syms);
  rx_data_bits_i = sign(rx_data_syms_i);	%contains 1, -1 and 0
  rx_data_bits_i = fix((rx_data_bits_i + 1)/2);	%contains 1 and 0 only

  %data.rx_data_bits_i = rx_data_bits_i;
  %data.rx_data_bits_q = rx_data_bits_q;
  %data.rx_data_bits_q = rx_data_bits_i;

  %[this_ndsubc this_nsyms] = size(rx_data_bits_i);
  %this_ndsubc_2 = (1:this_ndsubc)*2;
  %rx_data_bits(this_ndsubc_2 - 1, :) = data.rx_data_bits_i;
  %rx_data_bits(this_ndsubc_2, :) = data.rx_data_bits_q;
  rx_data_bits = rx_data_bits_i;
  rx_data_bits = rx_data_bits * 255;	%making bits soft
end

%----------------------------------------------------------------------------------------------------------------------------
function [stats data rx_data_bits] = demapPacket(rx_data_syms, nsyms, nbpsc, data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  if (prod(size(rx_data_syms)) == 0)
    return;
  end
  %stats.n_packets_processed = stats.n_packets_processed + 1;

  util_plotConstellation(rx_data_syms, opt);

  %rx_data_syms = reshape(rx_data_syms, prod(size(rx_data_syms)), 1);
  rx_data_bits = wifi_softSlice(rx_data_syms, nbpsc, opt.soft_slice_nbits);
end

%----------------------------------------------------------------------------------------------------------------------------
function util_print_demapPacket_plcp(rx_data_bits, opt)
%----------------------------------------------------------------------------------------------------------------------------
  %%%%%%%%%%%%%%%%%%%%%%%
    display('plcp signal field soft bits');
    nbits = opt.soft_slice_nbits;
    scale = 2^(nbits - 1);		%for 8 bits, this is 128, so that we can contain the soft estimates in [-128, 128]
    if (opt.printVars_softBits_plcp)
	    size(rx_data_bits)
	    size(scale)
	  %[[1:length(rx_data_bits)]' (rx_data_bits - scale)]	%representing in [-scale, scale], instead of [0, 2*scale]
	  [[1:size(rx_data_bits,1)]' (rx_data_bits(:,1) - scale)]	%representing in [-scale, scale], instead of [0, 2*scale]
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
	    pause
	  end
    end
  %%%%%%%%%%%%%%%%%%%%%%%
end

%----------------------------------------------------------------------------------------------------------------------------
function util_print_demapPacket_data(rx_data_bits, opt)
%----------------------------------------------------------------------------------------------------------------------------
  %%%%%%%%%%%%%%%%%%%%%%%
    display('data field soft bits');
    size(rx_data_bits)
    pause
    nbits = opt.soft_slice_nbits;
    scale = 2^(nbits - 1);		%for 8 bits, this is 128, so that we can contain the soft estimates in [-128, 128]
    if (opt.printVars_softBits_data)
	    size(rx_data_bits)
	    size(scale)
	    nsyms = size(rx_data_syms,2) - 1;
	    for i = 1:nsyms
		  %[[1:length(rx_data_bits)]' (rx_data_bits - scale)]	%representing in [-scale, scale], instead of [0, 2*scale]
		  [[1:size(rx_data_bits,1)]' (rx_data_bits(i+1,1) - scale)]	%representing in [-scale, scale], instead of [0, 2*scale]
		  pause
	    end
	    if (opt.PAUSE_AFTER_EVERY_PACKET)
	      pause
	    end
    end
  %%%%%%%%%%%%%%%%%%%%%%%
end


%----------------------------------------------------------------------------------------------------------------------------
function util_print_decode(rx_data_bits_dec, nbits_per_symbol, nchunks_per_symbol)
%----------------------------------------------------------------------------------------------------------------------------
  display('decoded bits, each ROW is a symbol (not each column)');
  size(rx_data_bits_dec)
  %pause
  nsyms = ceil(length(rx_data_bits_dec)/nbits_per_symbol)
  nbits_ceil = nsyms * (nbits_per_symbol)
  padlength = nbits_ceil - length(rx_data_bits_dec)
  rx_data_bits_dec =  [rx_data_bits_dec zeros(padlength, 1)];
  %dec_bits_reshape = reshape(rx_data_bits_dec, nbits_per_symbol, nsyms)';
  %dec_bits_out = [(1:nsyms)' dec_bits_reshape]
  nchunks = nsyms * nchunks_per_symbol;
  nbits_per_chunk = nbits_per_symbol/nchunks_per_symbol;
  dec_bits_reshape = reshape(rx_data_bits_dec, nbits_per_chunk, nchunks)';
  %dec_bits_out = dec_bits_reshape
  b = 2.^[7:-1:0]
  %dec2bin(sum(a.*b), 5)
  nbits_pad_chunk = 32 * ceil(nbits_per_chunk/32) - nbits_per_chunk
  pad_chunk = zeros(1, nbits_pad_chunk)
  noctets = (nbits_per_chunk + nbits_pad_chunk)/8
  nwords = noctets/4
  for i = 1:nchunks
    fprintf(1, 'chunk_number=%d\n', i)
    chunk = [dec_bits_reshape(i,:) pad_chunk];
    for j = 1:nwords
      si = 1 + (j-1)*32;
      word = chunk(si : si + 32 - 1);
      for k = 1:4
        octet = word(1+(k-1)*8 : k*8);
	os = dec2bin(sum(octet .* b), 8);
	fprintf(1, '%s ', os)
      end
      fprintf(1, '\n')
    end
  end
end

%----------------------------------------------------------------------------------------------------------------------------
function util_print_data_syms(opt, data, rx_data_syms_eq_const_pnts, rx_data_bits, rx_data_bits_deint, rx_data_bits_dec)
%----------------------------------------------------------------------------------------------------------------------------
  fprintf(1,'\nbegin util_print_data_syms');
  pause

  nsyms = size(rx_data_syms_eq_const_pnts, 2)
  factor = 60/0.93;

  factor_t = 848/0.0016;
  rx_data_syms_t_with_cp = fix(data.ofdm_syms_t_with_cp(:,2:end) * factor_t);

  rx_pilot_syms = fix(data.rx_pilot_syms(:,2:end) * factor_t);		%after chi
  %uu_pilot_syms = fix(data.uu_pilot_syms_after_chi(:,2:end) * factor_t);		%after chi
  uu_pilot_syms = fix(data.uu_pilot_syms_before_chi(:,2:end) * factor_t);		%after chi

  phase_correction_vector = fix(data.phase_correction_vector(:,2:end) * factor_t);

  rx_data_syms_before_chi = fix(data.rx_data_syms_before_chi(:,2:end) * factor_t);
  rx_data_syms_eq_const_pnts = fix(rx_data_syms_eq_const_pnts * factor);

  nbits = opt.soft_slice_nbits;
  scale = 2^(nbits - 1);		%for 8 bits, this is 128, so that we can contain the soft estimates in [-128, 128]

  rx_data_bits_deint = rx_data_bits_deint - 64;

  size(rx_data_syms_t_with_cp)
  size(rx_data_syms_before_chi)
  size(rx_pilot_syms)
  size(rx_data_syms_eq_const_pnts)
  size(rx_data_bits)
  size(rx_data_bits_deint)

  ncbps = length(rx_data_bits_deint)/nsyms;

  ndbps = data.sig_ndbps;

  for i = 1:nsyms
	  i = i
          symi_t_with_cp = [(1:80)' rx_data_syms_t_with_cp(:, i)]

	  fprintf(1,'\nconstellation points of after ofdm demod, data subcarriers, before eq\n');
	  i = i
          symi_uneq_pnts = [(1:48)' rx_data_syms_before_chi(:, i)]

	  i = i
	  symi_phase_corr_factor = phase_correction_vector(i)
  

	  i = i
          symi_pilot_syms = [(1:4)' rx_pilot_syms(:, i)]

	  i = i
          symi_uu_pilot_syms = [(1:4)' uu_pilot_syms(:, i)]

	  fprintf(1,'\nequalized constellation points of symbols\n');
	  i = i
          symi_eq_pnts = [(1:48)' rx_data_syms_eq_const_pnts(:, i)]

    	  display('data field soft bits');
	  [(1:48)' (rx_data_bits(:,i) - scale)]	%representing in [-scale, scale], instead of [0, 2*scale]

	  fprintf(1,'\ndeinterleaved bits\n');
  
	  symi = rx_data_bits_deint((ncbps * (i-1) + 1):(ncbps * i), 1);
	  i = i
	  symi_deint = reshape(symi, 4, length(symi)/4)'
	  pause

	  symi = rx_data_bits_dec((ndbps * (i-1) + 1):(ndbps * i), 1);
	  i = i;
	  %symi_dec = reshape(symi, 4 * 8, length(symi)/(4 * 8))'
	  symi_dec = symi';
	  symi_dec_bytes = util_bitsToBytes(symi_dec)

	  pause
  end
end


%----------------------------------------------------------------------------------------------------------------------------
function bytes = util_bitsToBytes(bit_vector)
%----------------------------------------------------------------------------------------------------------------------------
  l = length(bit_vector);
  if (mod(l,8) ~= 0)
	  error('number of bits not a multiple of 8','number of bits not a multiple of 8');
  end
  nBytes = l/8;
  bytes = reshape(bit_vector, 8, nBytes);	%each column is a byte, msb at the top
  pv = 2.^[7:-1:0];
  %pv = power(2,pv)
  %pv = diag(pv)
  %bytes
  decBytes = pv * bytes;
  bytes = dec2bin(decBytes);
end


%----------------------------------------------------------------------------------------------------------------------------
function util_plotConstellation(rx_data_syms, opt)
%----------------------------------------------------------------------------------------------------------------------------

  if (opt.GENERATE_PER_PACKET_PLOTS)
    rx_const_pnts = reshape(rx_data_syms, prod(size(rx_data_syms)), 1);
    figure
    subplot(2,2,1)
    %axis([-3 3 -3 3]); 
    plot(real(rx_const_pnts), imag(rx_const_pnts), 'b.')
    xlim([-3 3]);
    ylim([-3 3]); 
    grid on
    title('rx constellation map');
    axis equal;

    rx_data_syms_inner = rx_data_syms([13:36],:);
    rx_const_pnts_inner = reshape(rx_data_syms_inner, prod(size(rx_data_syms_inner)), 1);
    subplot(2,2,2)
    %axis([-3 3 -3 3]); 
    plot(real(rx_const_pnts_inner), imag(rx_const_pnts_inner), 'b.')
    xlim([-3 3]);
    ylim([-3 3]); 
    grid on
    title('rx constellation map, inner subcarriers');
    axis equal;

    rx_data_syms_outer = rx_data_syms([1:12 37:48],:);
    rx_const_pnts_outer = reshape(rx_data_syms_outer, prod(size(rx_data_syms_outer)), 1);
    subplot(2,2,3)
    %axis([-3 3 -3 3]); 
    plot(real(rx_const_pnts_outer), imag(rx_const_pnts_outer), 'b.')
    xlim([-3 3]);
    ylim([-3 3]); 
    grid on
    title('rx constellation map, outer subcarriers');
    axis equal;

    rx_data_syms_subc_1 = rx_data_syms([25],:);
    rx_const_pnts_subc_1 = reshape(rx_data_syms_subc_1, prod(size(rx_data_syms_subc_1)), 1);
    subplot(2,2,4)
    %axis([-3 3 -3 3]); 
    plot(real(rx_const_pnts_subc_1), imag(rx_const_pnts_subc_1), 'b.')
    xlim([-3 3]);
    ylim([-3 3]); 
    grid on
    title('rx constellation map, subc_1');
    axis equal;
  end
  %pause
end

%----------------------------------------------------------------------------------------------------------------------------
function [stats ber] = util_computeModulationBER(data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  ber = -1;
  stats.ber(end+1,:) = ber;

  if (~opt.tx_known)
    return;
  end

  rx_data_bits_i = data.rx_data_bits_i;
  rx_data_bits_q = data.rx_data_bits_q;

  tx_data_bits_i = data.tx_data_bits_i;
  tx_data_bits_q = data.tx_data_bits_q;


  bit_errors_i = rx_data_bits_i ~= tx_data_bits_i;

  display('no. of bit erros in i channel:')
  n_bit_errors_i = sum(sum(bit_errors_i))

  stats.n_bits_errors_i(end+1,:) = n_bit_errors_i;

  n_bit_errors = n_bit_errors_i;
  nbits = prod(size(tx_data_bits_i));

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % per subcarrier SNR using normalized symbols
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if (data.mod == 1)
    %tx_data_syms = (2*tx_data_bits_i - 1) + i * (2*tx_data_bits_q - 1);	%works for bpsk and qpsk, maps {1, 0} to {1, -1} 
    										%(also need to normalized with sqrt(2) for qpsk)
    tx_data_syms = (2*tx_data_bits_i - 1);
    uu_rx_data_syms = rx_data_syms .* tx_data_syms;	%uu_rx_data_syms normalizes each symbol to map to expected value 1
    mean_rx_symbol = sum(uu_rx_data_syms, 2)/size(uu_rx_data_syms,2);
    noise_matrix = uu_rx_data_syms - diag(mean_rx_symbol) * ones(size(uu_rx_data_syms));
    noise_power_per_subcarrier = sum(noise_matrix .* conj(noise_matrix), 2)/size(uu_rx_data_syms,2);
    signal_power_per_subcarrier = mean_rx_symbol .* conj(mean_rx_symbol);

    snr_per_subcarrier = signal_power_per_subcarrier./noise_power_per_subcarrier;
    snr_per_subcarrier_db = 10*log10(snr_per_subcarrier);

    display('snr values computed using normalized data symbols:');
    net_snr_linear = sum(signal_power_per_subcarrier)/sum(noise_power_per_subcarrier)
    net_snr_db = 10*log10(net_snr_linear)

    stats.net_snr_linear(end+1,:) = net_snr_linear;
    stats.net_snr_db(end+1,:) = net_snr_db;

    if (opt.GENERATE_PER_PACKET_PLOTS)
      figure
      subplot(2,1,1)
      plot(snr_per_subcarrier,'r.-');
      title('snr per subcarrier, linear');
      grid on

      subplot(2,1,2)
      plot(10*log10(snr_per_subcarrier),'r.-');
      title('snr per subcarrier, dB');
      grid on
      %v = axis;
      %v(3) = 0; v(4) = 30;
      %axis(v);
    end
    %pause
  end

  if (data.mod == 2)
    rx_data_syms_q = imag(rx_data_syms);
    rx_data_bits_q = sign(rx_data_syms_q);
    rx_data_bits_q = fix((rx_data_bits_q + 1)/2);	%contains 1 and 0 only

    bit_errors_q = rx_data_bits_q ~= tx_data_bits_q;

    display('no. of bit erros in q channel:')
    n_bit_errors_q = sum(sum(bit_errors_q))

    stats.n_bits_errors_q(end+1,:) = n_bit_errors_q;

    n_bit_errors = n_bit_errors_i + nbit_erros_q;
    nbits = nbits * 2;
  else
    bit_errors_q = zeros(size(bit_errors_i));
  end

  ndsubc = 48;

  n_bits_per_subcarrier = data.mod;
  bit_errors = bit_errors_i + bit_errors_q;		%contains 0, 1 and 2 as entries; 2 means both bits were in error in that symbol
  bit_errors_vs_ofdm_symbol = sum(bit_errors);

  ber_vs_ofdm_symbol = (bit_errors_vs_ofdm_symbol/(n_bits_per_subcarrier * ndsubc))';	%col vector -- easier to see on console
  ber_vs_subcarrier = (sum(bit_errors, 2)/(n_bits_per_subcarrier * size(bit_errors, 2)));	


  %display('ber vs ofdm symbol:');
  %ber_vs_ofdm_symbol

  display('snr(lin), snr(dB), ber per subcarrier:');
  [snr_per_subcarrier snr_per_subcarrier_db ber_vs_subcarrier]


  stats.ber_vs_ofdm_symbol(end+1,:) = ber_vs_ofdm_symbol';		%add a row
  stats.snr_per_subcarrier(end+1,:) = snr_per_subcarrier';		%add a row
  stats.snr_per_subcarrier_db(end+1,:) = snr_per_subcarrier_db';	%add a row
  stats.ber_vs_subcarrier(end+1,:) = ber_vs_subcarrier';		%add a row

  %val = opt.GENERATE_PER_PACKET_PLOTS;
  %opt.GENERATE_PER_PACKET_PLOTS = true;
  if (opt.GENERATE_PER_PACKET_PLOTS)
    figure
    subplot(2,1,1);
    plot(ber_vs_ofdm_symbol, 'r.-');
    title('BER vs OFDM symbol');

    subplot(2,1,2);
    plot(ber_vs_subcarrier, 'r.-');
    title('BER vs OFDM subcarrier');
  end
  %opt.GENERATE_PER_PACKET_PLOTS = val;

  ber = n_bit_errors/nbits;
  stats.ber(end) = ber;
end

%----------------------------------------------------------------------------------------------------------------------------
function [stats data rx_data_bits_deint] = deinterleave(data, opt, stats, rx_data_bits, nbpsc)
%----------------------------------------------------------------------------------------------------------------------------
  t = data.deinterleave_tables;
  %size(rx_data_bits)
  rx_data_bits_deint = wifi_deinterleave(t, rx_data_bits, nbpsc);
  %size(rx_data_bits_deint)

  if (opt.writeVars_deinterleave)
  writeVars_deinterleave(rx_data_bits, rx_data_bits_deint);
  end

  %%%%%%%%%%%%%%%%%%%%%%%
    if (opt.printVars_softBits_deint)
	  display('plcp signal field soft bits after deinterleaving');
	  nbits = opt.soft_slice_nbits;
	  scale = 2^(nbits - 1);		%for 8 bits, this is 128, so that we can contain the soft estimates in [-128, 128]
	  size(rx_data_bits_deint)
	  size(scale)
	  %[[1:length(rx_data_bits)]' (rx_data_bits - scale)]	%representing in [-scale, scale], instead of [0, 2*scale]
	  [[1:size(rx_data_bits_deint,1)]' (rx_data_bits_deint(:,1) - scale)]	%representing in [-scale, scale], instead of [0, 2*scale]
	  if (opt.PAUSE_AFTER_EVERY_PACKET)
	    pause
	  end
    end
  %%%%%%%%%%%%%%%%%%%%%%%

end

%----------------------------------------------------------------------------------------------------------------------------
function util_print_deinterleave(rx_data_bits_deint)
%----------------------------------------------------------------------------------------------------------------------------
  fprintf(1,'\nbegin util_print_deinterleave');

  fprintf(1,'\ndeinterleaved bits\n');
  size(rx_data_bits_deint)
  %rx_data_bits_deint = reshape(rx_data_bits_deint, prod(size(rx_data_bits_deint)), 1);
  %size(rx_data_bits_deint)

  %[rx_data_bits_deint(1:10) rx_data_bits_deint(1:10) - 64]
  rx_data_bits_deint = rx_data_bits_deint - 64;
  
  nsyms = size(rx_data_bits_deint, 2);
  %rx_data_bits_deint = rx_data_bits_deint';	%each row is a symbol

  for i = 1:nsyms
	  symi = rx_data_bits_deint(:, i);
	  i = i
	  symi_deint = reshape(symi, 4, length(symi)/4)'
	  pause
  end

  %pause

  %util_writeVarToCFile(rx_data_bits_deint, ['rx_data_bits_deint_len_',num2str(length(rx_data_bits_deint))], 0, 0, 'Int8', 1, 1);		%Qval = 0 corresponds to integer
  fprintf(1,'end util_print_deinterleave\n');
  %pause
end

%----------------------------------------------------------------------------------------------------------------------------
function [stats data rx_data_bits_depunct] = depuncture(data, opt, stats, rx_data_bits_deint, coderate)
%----------------------------------------------------------------------------------------------------------------------------
  rx_data_bits_depunct = wifi_softDepuncture(rx_data_bits_deint, opt.soft_slice_nbits, coderate);
  if (opt.writeVars_depuncture)
  writeVars_depuncture(rx_data_bits_deint, opt.soft_slice_nbits, coderate, rx_data_bits_depunct);
  end
end

%----------------------------------------------------------------------------------------------------------------------------
function [stats data rx_data_bits_dec] = decode(data, opt, stats, rx_data_bits_depunct, tblen)
%----------------------------------------------------------------------------------------------------------------------------
  rx_data_bits_dec = wifi_vdec(rx_data_bits_depunct, opt.soft_slice_nbits, tblen);
  if (opt.writeVars_decode)
  writeVars_decode(rx_data_bits_depunct, opt.soft_slice_nbits, tblen, rx_data_bits_dec);
  end
end

%----------------------------------------------------------------------------------------------------------------------------
function [rx_data_bits_descr] = descramble(rx_data_bits_dec)
%----------------------------------------------------------------------------------------------------------------------------
  rx_data_bits_descr = wifi_descramble(rx_data_bits_dec);
end

%----------------------------------------------------------------------------------------------------------------------------
function util_print_descramble(rx_data_bits_descr, nbits_per_symbol)
%----------------------------------------------------------------------------------------------------------------------------
  display('descrambled bits, each ROW is a symbol (not each column)');
  size(rx_data_bits_descr)
  pause
  nsyms = ceil(length(rx_data_bits_descr)/nbits_per_symbol)
  nbits_ceil = nsyms * (nbits_per_symbol)
  padlength = nbits_ceil - length(rx_data_bits_descr)
  rx_data_bits_descr =  [rx_data_bits_descr zeros(padlength, 1)];
  descr_bits_reshape = reshape(rx_data_bits_descr, nbits_per_symbol, nsyms)';
  descr_bits_out = [(1:nsyms)' descr_bits_reshape]
end


%----------------------------------------------------------------------------------------------------------------------------
function [stats data rx_data_bits_dec ndbps nsyms] = parse_signal(data, opt, stats, rx_data_bits_dec)
%----------------------------------------------------------------------------------------------------------------------------
  [rate length modu code parityCheck valid ndbps nsyms] = wifi_parse_signal(rx_data_bits_dec);
  display('------------------------------------------------------------');
  display('parse signal results: ');
  display(strcat('rate: ', num2str(rate), ' length: ', num2str(length), ' code: ', num2str(code), ...
  	' parityCheck: ', num2str(parityCheck), ' valid: ', num2str(valid), ...
	' ndbps: ', num2str(ndbps), ' nsyms:', num2str(nsyms)));
  display('------------------------------------------------------------');
  data.sig_rate = rate;
  data.sig_payload_length = length;
  data.sig_modu = modu;
  data.sig_code = code;
  data.sig_parityCheck = parityCheck;
  data.sig_valid = valid;
  data.sig_ndbps = ndbps;
  data.sig_nsyms = nsyms;
end


%----------------------------------------------------------------------------------------------------------------------------
function [parsed_data frame_type ber crcValid] = parse_payload(databytes)	%each column is a byte, top of a byte being the earliest bit
  %display('service field:');
  service_field = databytes(:,1:2)

  databytes = databytes(:,3:end);

  %function [parsed_data frame_type ber crcValid] = wifi_parse_phy_payload(databytes)
  %[data.parsed_data data.frame_type data.ber data.crcValid] = wifi_parse_phy_payload(databytes);
  [parsed_data frame_type ber crcValid] = wifi_parse_phy_payload(databytes);
end
%----------------------------------------------------------------------------------------------------------------------------

%----------------------------------------------------------------------------------------------------------------------------
function tx_pilot_syms = generate_pilot_syms(datalength_nsyms)
%----------------------------------------------------------------------------------------------------------------------------
  %pilot generative code

  nsubc = 64;

  % Pilot Subcarrier Sequence Generator %
  pilot_sc=[ 1,1,1,1, -1,-1,-1,1, -1,-1,-1,-1, 1,1,-1,1, -1,-1,1,1,...
      -1,1,1,-1, 1,1,1,1, 1,1,-1,1, 1,1,-1,1, 1,-1,-1,1, 1,1,-1,1, ...
      -1,-1,-1,1, -1,1,-1,-1, 1,-1,-1,1, 1,1,1,1, -1,-1,1,1,...
      -1,-1,1,-1, 1,-1,1,1, -1,-1,-1,1, 1,-1,-1,-1, -1,1,-1,-1, ...
      1,-1,1,1, 1,1,-1,1, -1,1,-1,1, -1,-1,-1,-1, -1,1,-1,1, 1,-1,1,-1,...
      1,1,1,-1, -1,1,-1,-1, -1,1,1,1, -1,-1,-1,-1, -1,-1,-1 ];

  pilot_sc_ext = [pilot_sc pilot_sc pilot_sc pilot_sc pilot_sc]; %127 * 5 = 635 long - enough for all packet lengths

  psubc_idx = (nsubc/2)+[(1+[-21 -7 7 21])];	%regular order (dc in middle)
  psubc_ind = zeros(nsubc,1);
  psubc_ind(psubc_idx) = 1;
  %[psubc_ind [1:64]']
  %%%psubc_ind_shifted = fftshift(psubc_ind)
  %%%psubc_idx_shifted = find(psubc_ind_shifted)     %[8; 22; 44; 58]

  % pilot symbols to load on the above indices: [1 -1 1 1] * polarity, (corresponding 
  % to [1 1 1 -1] * polarity in natural order)

  %%%pilotsyms = diag([1 -1 1 1]) * ones(4, datalength_nsyms);
  pilotsyms = diag([1 1 1 -1]) * ones(4, datalength_nsyms);

  polarity = pilot_sc_ext(1:datalength_nsyms);
  pilotsyms = pilotsyms * diag(polarity);
  %%%fpsyms = zeros(nsubc, datalength_nsyms);
  %%%fpsyms(psubc_idx_shifted, :) = pilotsyms

  tx_pilot_syms = pilotsyms;
end



%----------------------------------------------------------------------------------------------------------------------------
function plotSamples(samples)
%----------------------------------------------------------------------------------------------------------------------------
  plot(abs(samples))
end

%----------------------------------------------------------------------------------------------------------------------------
function p = power(samples)
%----------------------------------------------------------------------------------------------------------------------------
  p = sum(samples.*conj(samples))/length(samples);
end



%----------------------------------------------------------------------------------------------------------------------------
function writeVars_corr(corrvec, abscorrvec, abscorrvecsq, norm1val, norm2val, normval, corrwin, norm1terms, norm2terms, isMetricHigh)
%----------------------------------------------------------------------------------------------------------------------------
  util_writeVarToCFile(norm1terms, 'norm1terms', 0, 30, 'Uint32');
  %util_writeVarToCFile(norm1val, 'norm1val', ceil(log2(corrwin)), 30, 'Uint32');	%scale down by window size rounded to 
  											%(ceiled to) power of 2
  util_writeVarToCFile(norm1val, 'norm1val', 0, 30, 'Uint32');				%no scaling down
  util_writeVarToCFile(norm1val .* norm1val, 'norm1sqval', 0, 30, 'Uint32');				%no scaling down

  util_writeVarToCFile(isMetricHigh, 'isMetricHigh', 0, 0, 'Uint32');			%Qval = 0 corresponds to integer
end

%----------------------------------------------------------------------------------------------------------------------------
function writeVars_startPnts(pkt_start_points)
%----------------------------------------------------------------------------------------------------------------------------
  whos
  pkt_start_points(1:10)
  pkt_start_points(end)=[];	%removes the -Inf at the end
  util_writeVarToCFile(pkt_start_points, 'pkt_start_points', 0, 0, 'Uint32', 1, 1);			%Qval = 0 corresponds to integer
end

%----------------------------------------------------------------------------------------------------------------------------
function writeVars_deinterleave(rx_data_bits, rx_data_bits_deint)
%----------------------------------------------------------------------------------------------------------------------------
  fprintf(1,'\nbegin writeVars_deinterleave');

  fprintf(1,'\ndeinterleaved bits\n');
  size(rx_data_bits_deint)
  rx_data_bits_deint = reshape(rx_data_bits_deint, prod(size(rx_data_bits_deint)), 1);
  size(rx_data_bits_deint)

  [rx_data_bits_deint(1:10) rx_data_bits_deint(1:10) - 64]
  rx_data_bits_deint = rx_data_bits_deint - 64;
  pause

  util_writeVarToCFile(rx_data_bits_deint, ['rx_data_bits_deint_len_',num2str(length(rx_data_bits_deint))], 0, 0, 'Int8', 1, 1);		%Qval = 0 corresponds to integer
  fprintf(1,'end writeVars_deinterleave\n');
  pause
end

%----------------------------------------------------------------------------------------------------------------------------
function writeVars_depuncture(rx_data_bits_deint, soft_slice_nbits, coderate, rx_data_bits_depunct)
%----------------------------------------------------------------------------------------------------------------------------
  fprintf(1,'\nbegin writeVars_depuncture');

  fprintf(1,'\ndepunctured bits\n');

  size(rx_data_bits_depunct)
  rx_data_bits_depunct = reshape(rx_data_bits_depunct, prod(size(rx_data_bits_depunct)), 1);
  size(rx_data_bits_depunct)

  [rx_data_bits_depunct(1:10) rx_data_bits_depunct(1:10) - 64]
  rx_data_bits_depunct = rx_data_bits_depunct - 64;
  pause

  util_writeVarToCFile(rx_data_bits_depunct, ['rx_data_bits_depunct_len_',num2str(length(rx_data_bits_depunct))], 0, 0, 'Int8', 1, 1);		%Qval = 0 corresponds to integer
  fprintf(1,'end writeVars_depuncture\n');
  pause
end

%----------------------------------------------------------------------------------------------------------------------------
function writeVars_decode(rx_data_bits_depunct, nbits_precision, tblen, rx_data_bits_dec)
%----------------------------------------------------------------------------------------------------------------------------
  fprintf(1,'\nbegin writeVars_decode');
  pause
  util_writeVarToCFile(rx_data_bits_dec, ['rx_data_bits_dec_len_',num2str(length(rx_data_bits_dec))], 0, 0, 'Uint8', 1, 1);			%Qval = 0 corresponds to integer
  fprintf(1,'end writeVars_decode\n');
  pause
end

%----------------------------------------------------------------------------------------------------------------------------
function writeVars_cfos(coarse_cfo_freq_off_khz, fine_cfo_freq_off_khz)
%----------------------------------------------------------------------------------------------------------------------------
  fprintf(1,'\nbegin writeVars_cfos\n');
  pause
  cfo_khz = coarse_cfo_freq_off_khz + fine_cfo_freq_off_khz;	%since on TI, we do a single estimate
  util_writeVarToCFile(cfo_khz, 'cfo_khz', 0, 0, 'float', 1, 1);
  fprintf(1,'end writeVars_cfos\n');
  pause
end
