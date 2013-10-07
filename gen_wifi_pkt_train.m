function gen_wifi_pkt_train(scale)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Configuration parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  %writeFiles = false;
  writeFiles = true;
  DATA_DIR = '../wifibb-traces/data'

  if (nargin < 1)
    %scale = 1;		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
    %scale = 256;		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
    scale = sqrt(2);		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
  end


  %%%%%%%%%%%%%%
  %% pick a rate
  %%%%%%%%%%%%%%
  rate = 54;
  %rate = 36;
  %rate = 24;
  %rate = 6;
  %rate = 12;


  %%%%%%%%%%%%%%
  %% pick an snr
  %%%%%%%%%%%%%%
  snr = Inf;
  %snr = 30;
  %snr = 17; 	

  %%%%%%%%%%%%%%%%%%%%%%
  %% pick the message(s)
  %%%%%%%%%%%%%%%%%%%%%%
  msgs_hex = util_msg_hex()
  n_msgs = length(msgs_hex)

  %%%%%%%%%%%%%%%%%%%%%%
  %% modulate messages
  %%%%%%%%%%%%%%%%%%%%%%
  td_pkt_samples_16bit = wifi_tx_pkt_train(msgs_hex, rate, snr, scale);
  n_tx_samples = length(td_pkt_samples_16bit)
  pause

  if (writeFiles)
    %%%%%%%%%%%%%%%%%%%
    dt = datestr(now, 'yyyymmdd_HHMMSS')
    %%pktparams = strcat('nsyms_',int2str(nsyms),'_mod_',int2str(mod),'_scale_',int2str(scale));
    %%pktparams = strcat('nsyms_',int2str(nsyms),'_mod_',int2str(MOD),'_scale_',num2str(scale));
    %pktparams = strcat('nbits',int2str(base_msg_len_bits),'_rate_',int2str(rate),'_scale_',num2str(scale));
    pktparams = strcat('nmsgs',int2str(n_msgs),'_rate_',int2str(rate),'_snr_',num2str(snr),'_scale_',num2str(scale));

    pktTxtFile = strcat(DATA_DIR, '/txpkt_',pktparams,'.txt');
    pktBinFile = strcat(DATA_DIR, '/txpkt_',pktparams,'.dat');
    %iBitsFile  = strcat(DATA_DIR, '/ibits_',pktparams,'.mat');
    %qBitsFile  = strcat(DATA_DIR, '/qbits_',pktparams,'.mat');
    %symbsFile  = strcat(DATA_DIR, '/symbs_',pktparams,'.mat');

    t_pktTxtFile = strcat(DATA_DIR, '/txpkt_',pktparams,'_',dt,'.txt');
    t_pktBinFile = strcat(DATA_DIR, '/txpkt_',pktparams,'_',dt,'.dat');
    %t_iBitsFile  = strcat(DATA_DIR, '/ibits_',pktparams,'_',dt,'.mat');
    %t_qBitsFile  = strcat(DATA_DIR, '/qbits_',pktparams,'_',dt,'.mat');
    %t_symbsFile  = strcat(DATA_DIR, '/symbs_',pktparams,'_',dt,'.mat');


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

    fprintf(1, 'Writing to %s\n', t_pktTxtFile);
    fprintf(1, 'Writing to %s\n', t_pktBinFile);

    util_writeSamplesToTextFile(t_pktTxtFile, td_pkt_samples_16bit)
    util_writeSamplesToBinaryFile(t_pktBinFile, td_pkt_samples_16bit);
    %save(t_iBitsFile, 'databits_i');
    %save(t_qBitsFile, 'databits_q');
    %save(t_symbsFile, 'datasyms');

    fprintf(1, 'Writing to %s\n', pktTxtFile);
    fprintf(1, 'Writing to %s\n', pktBinFile);

    util_writeSamplesToTextFile(pktTxtFile, td_pkt_samples_16bit)
    util_writeSamplesToBinaryFile(pktBinFile, td_pkt_samples_16bit);
    %save(iBitsFile, 'databits_i');
    %save(qBitsFile, 'databits_q');
    %save(symbsFile, 'datasyms');
  else
    display('not writing any files');
  end
end
