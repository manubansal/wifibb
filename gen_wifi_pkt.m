function gen_wifi_pkt(scale)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Configuration parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  writeFiles = false;
  DATA_DIR = '../wifibb-traces/data'

  if (nargin < 1)
    %scale = 1;		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
    %scale = 256;		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
    scale = sqrt(2);		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
  end
  

  zero_pad_dur_us = 100;		%zero samples of this duration (us) will be prefixed to the packet


  %MOD = 1;	%bpsk
  MOD = 2;	%qpsk

  %nsyms = 10;		%number of ofdm symbols in data part of the packet
  %nsyms = 2;		%number of ofdm symbols in data part of the packet
  %nsyms = 250;		%number of ofdm symbols in data part of the packet
  nsyms = 35;		%number of ofdm symbols in data part of the packet


  %%%%%%%%%%%%%%
  %% pick a rate
  %%%%%%%%%%%%%%
  %rate = 54;
  %rate = 36;
  %rate = 24;
  %rate = 6;
  rate = 12;

  %%%%%%%%%%%%%%%%%%%
  %% pick the message
  %%%%%%%%%%%%%%%%%%%
  %msg_hex = [
  %'04'; '02'; '00'; '2e'; '00'; '60'; '08'; 'cd'; '37'; 'a6'; '00'; '20'; 'd6'; '01'; '3c'; 'f1'; '00'; '60'; '08'; 'ad'; '3b'; 'af'; '00'; '00'; '4a'; '6f'; '79'; '2c'; '20'; '62'; '72'; '69'; '67'; '68'; '74'; '20'; '73'; '70'; '61'; '72'; '6b'; '20'; '6f'; '66'; '20'; '64'; '69'; '76'; '69'; '6e'; '69'; '74'; '79'; '2c'; '0a'; '44'; '61'; '75'; '67'; '68'; '74'; '65'; '72'; '20'; '6f'; '66'; '20'; '45'; '6c'; '79'; '73'; '69'; '75'; '6d'; '2c'; '0a'; '46'; '69'; '72'; '65'; '2d'; '69'; '6e'; '73'; '69'; '72'; '65'; '64'; '20'; '77'; '65'; '20'; '74'; '72'; '65'; '61'; 'da'; '57'; '99'; 'ed']

  %msg_hex = [
  %'04'; '02'; '00'; '2e'; '00'; '60'; '08'; 'cd';]
  %msg_hex = [
  %'04'; '02';] 
  msg_hex = [
  '04'; '02'; '00'; '2e';] 

  %%%%%%%%%%%%%%%%%%%%%%
  %% pick other settings
  %%%%%%%%%%%%%%%%%%%%%%
  softbit_scale_nbits = 6;	%soft-bit scale
  %softbit_scale_nbits = 8;	%soft-bit scale
  tblen = 36;
  %tblen = 72;

  snr = 30;
  %snr = 17; 	
  
  %54mbps
  %snr 15	16	17	18
  %ber 0.1412 	0.0275	0	0

  softbit_scale = 2^softbit_scale_nbits - 1;


  %%%%%%%%%%%%%%%%%%%
  dt = datestr(now, 'yyyymmdd_HHMMSS')
  %%pktparams = strcat('nsyms_',int2str(nsyms),'_mod_',int2str(mod),'_scale_',int2str(scale));
  pktparams = strcat('nsyms_',int2str(nsyms),'_mod_',int2str(MOD),'_scale_',num2str(scale));

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

  msg_dec = hex2dec(msg_hex);
  %msg_dec = msg_dec(1:15)
  %pause

  msg = dec2bin(msg_dec, 8);
  msg = fliplr(msg);	%lsb msb flip
  msg = msg';
  msg = reshape(msg, prod(size(msg)), 1);
  msg = str2num(msg);

  %msg_len = 500;
  %msg = randint(msg_len,1);

  base_msg = msg;
  base_msg_len_bits = length(base_msg);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Generate pkt portions
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  zero_pad_samples = zeros(20 * zero_pad_dur_us - 1, 1); 	%-1 in zero-pad-length is because data portion is generated with one

  %--------------------------------------------------------------------------
  [samples_f, n_ofdm_syms, databits_i, databits_q] = wifi_tx_chain(msg, rate);
  %[td_data_samples databits_i databits_q datasyms] = gen_random_data_samples(MOD, nsyms);
  %[td_data_samples databits_i databits_q datasyms] = gen_random_data_samples(MOD, n_ofdm_syms);
  [td_data_samples databits_i databits_q datasyms] = gen_random_data_samples(MOD, n_ofdm_syms, databits_i, databits_q);

  s1 = size(samples_f)
  s3 = size(datasyms)
  s2 = size(td_data_samples)
  pause

  datasyms_f = reshape(datasyms, prod(size(datasyms)), 1)
  size(datasyms_f)
  comp = [samples_f datasyms_f   samples_f - datasyms_f]
  pause
  %--------------------------------------------------------------------------

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %% let's add some AWGN noise
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %%rx_samples_f = awgn(samples_f, snr, 'measured');
  %rx_samples_f = samples_f;


  % add preamble
  td_pkt_samples = util_prepend_preamble(td_data_samples)

  %--------------------------------------------------------------------------

  %%Here is the complete short sync OFDM symbol, with ones padding the end:
  %short_sync_time_total = [window_func.*short_sync_time_total(1:161,1);
  %                           0.2*ones(161,1)];
  %short_sync_time_total_16bit = round(3*short_sync_time_total*32767/1.0);

  %stf_sync_total_16bit = round(stf_sync_total*32767/1.0*3);
  %ltf_sync_total_16bit = round(ltf_sync_total*32767/1.0*3);

  %scale samples down by the given input factor to modify tx gain
  td_pkt_samples = td_pkt_samples/scale;


  td_pkt_samples_16bit = round(td_pkt_samples*32767/1.0*3);

  display('number of samples in data packet: ')
  n_samples = length(td_pkt_samples_16bit)
  display('data packet duration (us):')
  dur_us = n_samples/20

  td_pkt_samples_16bit = [zero_pad_samples; td_pkt_samples_16bit];
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

  pause

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

    writeSamplesToTextFile(t_pktTxtFile, td_pkt_samples_16bit)
    writeSamplesToBinaryFile(t_pktBinFile, td_pkt_samples_16bit);
    save(t_iBitsFile, 'databits_i');
    save(t_qBitsFile, 'databits_q');
    save(t_symbsFile, 'datasyms');

    writeSamplesToTextFile(pktTxtFile, td_pkt_samples_16bit)
    writeSamplesToBinaryFile(pktBinFile, td_pkt_samples_16bit);
    save(iBitsFile, 'databits_i');
    save(qBitsFile, 'databits_q');
    save(symbsFile, 'datasyms');
  else
    display('not writing any files');
  end
end


%-------------------------------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions to write txt 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function writeSamplesToTextFile(filename, samples)
  fid=fopen(filename,'w');
  for ii = 1:length(samples)
  %    save('preamble_oversampled.txt','-ascii','pciri');
      fprintf(fid,'{%4d, %4d},\n',real(samples(ii)),imag(samples(ii)));
  end
  fclose(fid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions to write binary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function writeSamplesToBinaryFile(filename, samples, len)
  if (nargin == 2)
    len = length(samples)
  end
  fid=fopen(filename,'w');
  rr=real(samples(1:len));
  ii=imag(samples(1:len));
  ri = [rr ii].';
  %display('writing the following as interleaved 16bit signed integers in column order to binary file:')
  %ri
  fwrite(fid, ri, 'int16');
  fclose(fid);
end


%---------------------------------------------------------------------------------------------------------

%fid=fopen('preamble_stf_ltf_Q14.txt','w');
%for ii = 1:length(stf_ltf_sync_total_Q14)
%    fprintf(fid,'{%5d, %5d},\n',real(stf_ltf_sync_total_Q14(ii)  ),imag(stf_ltf_sync_total_Q14(ii)));
%end
%fclose(fid);


%test_vector = [zeros(100,1); stf_ltf_sync_total_16bit; zeros(100,1) ]
%test_vector = test_vector + [zeros(100,1); 1000*(randn(length(test_vector)-100,1)+j*randn(length(test_vector)-100,1)) ];
%L = 16;
%corr_window = 5*L;
%for ii=81:(length(test_vector) - 79)
%    autocorr_P(ii) = (test_vector( (ii-80) : (ii-1) ))'*test_vector(ii : (ii+79) ) ;
%    energy_R(ii) = test_vector(ii : (ii+79) )'*test_vector(ii : (ii+79) );
%end
%plot( (autocorr_P .* conj(autocorr_P))./energy_R.^2  )
%autocorr_P
%energy_R



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Write ltf to a text file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%fid=fopen('preamble_ltf.txt','w');
%%for ii = 1:length(ltf_sync_total_16bit)
%%%    save('preamble_oversampled.txt','-ascii','pciri');
%%    fprintf(fid,'{%5d, %5d},\n',real(ltf_sync_total_16bit(ii)  ),imag(ltf_sync_total_16bit(ii)));
%%end
%%fclose(fid);                           
%% 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Write stf, ltf to a text file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%fid=fopen('preamble_stf_ltf.txt','w');
%%for ii = 1:length(stf_ltf_sync_total_16bit)
%%%    save('preamble_oversampled.txt','-ascii','pciri');
%%    fprintf(fid,'{%5d, %5d},\n',real(stf_ltf_sync_total_16bit(ii)  ),imag(stf_ltf_sync_total_16bit(ii)));
%%end
%%fclose(fid);

%%%manu
%%stf_ltf_sync_total_Q14 = round(stf_ltf_sync_total * 2^14);  %for Q14
%%disp('displaying the maximum real and imaginary components in generated preamble');
%%disp('make sure they are not over 32767, the maximum permissible 16 bit value');
%%max(real(stf_ltf_sync_total_Q14))
%%max(imag(stf_ltf_sync_total_Q14))
%%pause

