
function gen_wifi_pkt_random(scale)


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Configuration parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  writeFiles = false;
  DATA_DIR = '../wifibb-traces/data'

  mod = 1;	%bpsk
  %mod = 2;	%qpsk

  %nsyms = 10;		%number of ofdm symbols in data part of the packet
  %nsyms = 2;		%number of ofdm symbols in data part of the packet
  nsyms = 250;		%number of ofdm symbols in data part of the packet

  if (nargin < 1)
    %scale = 1;		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
    %scale = 256;		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
    scale = sqrt(2);		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
  end
  
  dt = datestr(now, 'yyyymmdd_HHMMSS')
  %%pktparams = strcat('nsyms_',int2str(nsyms),'_mod_',int2str(mod),'_scale_',int2str(scale));
  pktparams = strcat('nsyms_',int2str(nsyms),'_mod_',int2str(mod),'_scale_',num2str(scale));
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

  zero_pad_dur_us = 100;		%zero samples of this duration (us) will be prefixed to the packet


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Generate pkt portions
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  zero_pad_samples = zeros(20 * zero_pad_dur_us - 1, 1); 	%-1 in zero-pad-length is because data portion is generated with one
  								%extra sample due to windowing. this makes the length exactly match up.
  [ig1, ig2, stf_sync_total] = wifi_shortTrainingField();
  ltf_sync_total = wifi_longTrainingField();

  [td_data_samples databits_i databits_q datasyms] = wifi_random_data_samples(mod, nsyms);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Join stf and ltf
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [[stf_sync_total; zeros(160,1)] [zeros(160,1); ltf_sync_total]];
  %pause

  stf_ltf_sync_total = [ stf_sync_total; zeros(160,1)] + [zeros(160,1); ltf_sync_total];
  %stf_ltf_sync_total_16bit = round(stf_ltf_sync_total*32767/1.0*3);

  size(stf_ltf_sync_total)
  %pause


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Join preamble and data
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % stf_ltf_sync_total is 321 samples long
  % td_data_samples is to be joined by overlapping the 321'st sample of preamble

  td_pkt_samples = [stf_ltf_sync_total(1:end-1); td_data_samples];
  td_pkt_samples(321) = td_pkt_samples(321) + stf_ltf_sync_total(321);
  %size(td_pkt_samples)
  %pause

  %---------------------------------------------------------------------------------------------------

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

