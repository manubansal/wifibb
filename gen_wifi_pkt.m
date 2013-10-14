function gen_wifi_pkt(scale)
  %DATA_DIR = '../wifibb-traces/data'
  [DATA_DIR, TRACE_DIR] = setup_paths()

  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Configuration parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  writeFiles = false;

  if (nargin < 1)
    %scale = 1;		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
    %scale = 256;		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
    scale = sqrt(2);		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
  end
  

  zero_prepad_dur_us = 100;		%zero samples of this duration (us) will be prefixed to the packet


  %%%%%%%%%%%%%%
  %% pick a rate
  %%%%%%%%%%%%%%
  %rate = 54;
  %rate = 36;
  %rate = 24;
  %rate = 6;
  rate = 12;


  %%%%%%%%%%%%%%
  %% pick an snr
  %%%%%%%%%%%%%%
  snr = 30;
  %snr = 17; 	
  
  %54mbps
  %snr 15	16	17	18
  %ber 0.1412 	0.0275	0	0


  %%%%%%%%%%%%%%%%%%%%%%
  %% pick the message(s)
  %%%%%%%%%%%%%%%%%%%%%%
  msgs_hex = util_msg_hex();
  msg_hex = msgs_hex{1}

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% preprocess and encode message
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  msg_dec = hex2dec(msg_hex);
  %msg_dec = msg_dec(1:15)
  %pause

  msg = dec2bin(msg_dec, 8);
  msg = fliplr(msg);	%lsb msb flip
  msg = msg';
  msg = reshape(msg, prod(size(msg)), 1);
  msg = str2num(msg);

  base_msg = msg;
  base_msg_len_bits = length(base_msg);

  % generate data samples
  %--------------------------------------------------------------------------
  [samples_f, n_ofdm_syms, databits_i, databits_q, td_data_samples, td_pkt_samples] = wifi_tx_chain(msg, rate);
  %--------------------------------------------------------------------------


  %%%%%%%%%%%%%%%%%%%
  dt = datestr(now, 'yyyymmdd_HHMMSS')
  %%pktparams = strcat('nsyms_',int2str(nsyms),'_mod_',int2str(mod),'_scale_',int2str(scale));
  %%pktparams = strcat('nsyms_',int2str(nsyms),'_mod_',int2str(MOD),'_scale_',num2str(scale));
  pktparams = strcat('nbits',int2str(base_msg_len_bits),'_rate_',int2str(rate),'_scale_',num2str(scale));

  pktTxtFile = strcat(DATA_DIR, '/txpkt_',pktparams,'.txt');
  pktBinFile = strcat(DATA_DIR, '/txpkt_',pktparams,'.dat');
  iBitsFile  = strcat(DATA_DIR, '/ibits_',pktparams,'.mat');
  qBitsFile  = strcat(DATA_DIR, '/qbits_',pktparams,'.mat');
  symbsFile  = strcat(DATA_DIR, '/symbs_',pktparams,'.mat');

  t_pktTxtFile = strcat(DATA_DIR, '/txpkt_',pktparams,'_',dt,'.txt');
  t_pktBinFile = strcat(DATA_DIR, '/txpkt_',pktparams,'_',dt,'.dat');
  t_iBitsFile  = strcat(DATA_DIR, '/ibits_',pktparams,'_',dt,'.mat');
  t_qBitsFile  = strcat(DATA_DIR, '/qbits_',pktparams,'_',dt,'.mat');
  t_symbsFile  = strcat(DATA_DIR, '/symbs_',pktparams,'_',dt,'.mat');

  %%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%



  magnitudes = abs(td_pkt_samples)
  signal_rms = rms(td_pkt_samples)

  zero_prepad_samples = zeros(20 * zero_prepad_dur_us - 1, 1); 	
  %-1 in zero-pad-length is because data portion is generated with one
  %extra sample for windowing


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% let's add some AWGN noise
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %%rx_samples_f = awgn(samples_f, snr, 'measured');
  %rx_samples_f = samples_f;



  %scale samples down by the given input factor to modify tx gain
  td_pkt_samples = td_pkt_samples/scale;


  td_pkt_samples_16bit = round(td_pkt_samples*32767/1.0*3);

  display('number of samples in data packet: ')
  n_samples = length(td_pkt_samples_16bit)
  display('data packet duration (us):')
  dur_us = n_samples/20

  td_pkt_samples_16bit = [zero_prepad_samples; td_pkt_samples_16bit];
  display('number of samples in zero-padded packet: ')
  n_samples = length(td_pkt_samples_16bit)
  display('zero-padded packet duration (us):')
  dur_us = n_samples/20

  disp('displaying the maximum real and imaginary components in generated packet');
  disp('make sure they are not over 32767, the maximum permissible 16 bit value');

  max_real=max(real(td_pkt_samples_16bit))
  max_imag=max(imag(td_pkt_samples_16bit))

  if (max_real > 32767 || max_imag > 32767)
    error('max exceeded','maximum value of a sample exceed dynamic range');
  end

  if (writeFiles)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Write pkt to a text file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Write data bits to files
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Write pkt to a binary file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %writeSamplesToTextFile('stf.txt', short_sync_time_total)
    %writeSamplesToBinaryFile('stf160.dat', short_sync_time_total_16bit, 160);
    %writeSamplesToBinaryFile('stf_padded.dat', short_sync_time_total_16bit);

    util_writeSamplesToTextFile(t_pktTxtFile, td_pkt_samples_16bit)
    util_writeSamplesToBinaryFile(t_pktBinFile, td_pkt_samples_16bit);
    save(t_iBitsFile, 'databits_i');
    save(t_qBitsFile, 'databits_q');
    save(t_symbsFile, 'datasyms');

    util_writeSamplesToTextFile(pktTxtFile, td_pkt_samples_16bit)
    util_writeSamplesToBinaryFile(pktBinFile, td_pkt_samples_16bit);
    save(iBitsFile, 'databits_i');
    save(qBitsFile, 'databits_q');
    save(symbsFile, 'datasyms');
  else
    display('not writing any files');
  end
end
