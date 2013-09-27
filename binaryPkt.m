
function binaryPkt(scale)


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Configuration parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  writeFiles = false;

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

  pktTxtFile = strcat('data/txpkt_',pktparams,'.txt');
  pktBinFile = strcat('data/txpkt_',pktparams,'.dat');
  iBitsFile  = strcat('data/ibits_',pktparams,'.mat');
  qBitsFile  = strcat('data/qbits_',pktparams,'.mat');
  symbsFile  = strcat('data/symbs_',pktparams,'.mat');

  t_pktTxtFile = strcat('data/txpkt_',pktparams,'_',dt,'.txt');
  t_pktBinFile = strcat('data/txpkt_',pktparams,'_',dt,'.dat');
  t_iBitsFile  = strcat('data/ibits_',pktparams,'_',dt,'.mat');
  t_qBitsFile  = strcat('data/qbits_',pktparams,'_',dt,'.mat');
  t_symbsFile  = strcat('data/symbs_',pktparams,'_',dt,'.mat');

  zero_pad_dur_us = 100;		%zero samples of this duration (us) will be prefixed to the packet


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Generate pkt portions
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  zero_pad_samples = zeros(20 * zero_pad_dur_us - 1, 1); 	%-1 in zero-pad-length is because data portion is generated with one
  								%extra sample due to windowing. this makes the length exactly match up.
  stf_sync_total = generate_stf();
  ltf_sync_total = generate_ltf();
  [td_data_samples databits_i databits_q datasyms] = generate_data(mod, nsyms);


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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate stf portion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stf_sync_total = generate_stf()
  short_sync_freq_domain = zeros(64,1);

  index_offset = 33;
  %NOTE: SQRT(13/6) IS 1.472
  short_sync_freq_domain(-24 + index_offset) = 1.472 + 1.472*j;
  short_sync_freq_domain(-20 + index_offset) = -1.472 - 1.472*j; 
  short_sync_freq_domain(-16 + index_offset) = 1.472 + 1.472*i ;
  short_sync_freq_domain(-12 + index_offset) = -1.472 - 1.472*i ;
  short_sync_freq_domain(-8 + index_offset)  = -1.472 - 1.472*i ;
  short_sync_freq_domain(-4 + index_offset)  = 1.472 + 1.472*i ;
  short_sync_freq_domain(4 + index_offset)   = -1.472 - 1.472*i;
  short_sync_freq_domain(8 + index_offset)   = -1.472 - 1.472*i;
  short_sync_freq_domain(12 + index_offset)  = 1.472 + 1.472*i;
  short_sync_freq_domain(16 + index_offset)  = 1.472 + 1.472*i;
  short_sync_freq_domain(20 + index_offset)  = 1.472 + 1.472*i;
  short_sync_freq_domain(24 + index_offset)  = 1.472 + 1.472*i;



  short_sync_time_oneperiod = ifft(ifftshift(short_sync_freq_domain));

  %s = short_sync_time_oneperiod

  TOTAL_SAMPLES = 161;

  %REPEAT 3 TIMES, FOR A TOTAL OF 192 SAMPLES, AND DELETE THE LAST 31
  short_sync_time_total = repmat(short_sync_time_oneperiod,3,1);
  window_func = [0.5 ones(1,159) 0.5]';
  stf_sync_total = window_func.*[ short_sync_time_total(1:161,1)];

end


%-------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the LTF portion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ltf_sync_total = generate_ltf()
  ltf_sync_freq_domain = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0, ...
			  1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1]';
  ltf_sync_freq_domain = [ zeros(6,1); ltf_sync_freq_domain; zeros(5,1)];

  ltf_sync_time_oneperiod = (ifft(ifftshift(ltf_sync_freq_domain)));

  window_func = [0.5 ones(1,159) 0.5]';
  %add cp and double the length, and multiply by the window function
  ltf_sync_total = window_func.*[ltf_sync_time_oneperiod( (33):64); 
				  ltf_sync_time_oneperiod; 
				  ltf_sync_time_oneperiod;
				  ltf_sync_time_oneperiod(1)];
                            
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate data portion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [td_data_samples databits_i databits_q datasyms] = generate_data(mod, nsyms)
  bpskmap = [1, -1];
  bpskbmap_i = [1, 0];
  bpskbmap_q = [0, 0];
  qpskmap = [1+i, 1-i, -1-i, -1+i]/sqrt(2);
  qpskbmap_i = [1, 1, 0, 0];
  qpskbmap_q = [1, 0, 0, 1];

  if (mod == 1)
    cmap = bpskmap;
    bmap_i = bpskbmap_i;
    bmap_q = bpskbmap_q;
  elseif (mod == 2)
    cmap = qpskmap;
    bmap_i = qpskbmap_i;
    bmap_q = qpskbmap_q;
  else
    error ('badmod', 'bad modulation index');
  end

  cplength = 16;

  nsubc = 64; 			%number of subcarriers
  ndatasubc = 48;
  npsubc = 4;
  ndatapilotsubc = ndatasubc + npsubc;
  %npadsubcleft = 6;
  %npadsubcright = 5;
  %pause

  dsubc_idx = (nsubc/2)+[(1+[-26:-22 -20:-8 -6:-1]) (1+[1:6 8:20 22:26])];	%regular order (dc in middle)
  dsubc_ind = zeros(nsubc,1);
  dsubc_ind(dsubc_idx) = 1;
  [dsubc_ind [1:64]'];
  dsubc_ind_shifted = fftshift(dsubc_ind);
  dsubc_idx_shifted = find(dsubc_ind_shifted);

  idxs=randint(ndatasubc,nsyms,[1 length(cmap)]);
  datasyms = cmap(idxs);

  %I- and Q-channel data bits
  databits_i = bmap_i(idxs);
  databits_q = bmap_q(idxs);
  %pause

  %size(datasyms(ndatasubc/2+1:end, :))
  %size(datasyms(1:ndatasubc/2,:))

  datasyms_shifted = [datasyms(ndatasubc/2+1:end,:); datasyms(1:ndatasubc/2,:)];
  fdsyms = zeros(nsubc, nsyms);
  %dsubc_idx_shifted
  %pause
  fdsyms(dsubc_idx_shifted, :) = datasyms_shifted;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %add pilot subcarriers
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Pilot Subcarrier Sequence Generator %
  pilot_sc=[ 1,1,1,1, -1,-1,-1,1, -1,-1,-1,-1, 1,1,-1,1, -1,-1,1,1,...
      -1,1,1,-1, 1,1,1,1, 1,1,-1,1, 1,1,-1,1, 1,-1,-1,1, 1,1,-1,1, ...
      -1,-1,-1,1, -1,1,-1,-1, 1,-1,-1,1, 1,1,1,1, -1,-1,1,1,...
      -1,-1,1,-1, 1,-1,1,1, -1,-1,-1,1, 1,-1,-1,-1, -1,1,-1,-1, ...
      1,-1,1,1, 1,1,-1,1, -1,1,-1,1, -1,-1,-1,-1, -1,1,-1,1, 1,-1,1,-1,...
      1,1,1,-1, -1,1,-1,-1, -1,1,1,1, -1,-1,-1,-1, -1,-1,-1 ];

  pilot_sc_ext = [pilot_sc pilot_sc pilot_sc pilot_sc pilot_sc]; %127 * 5 = 635 long - enough for all packet lengths

  psubc_idx = (nsubc/2)+[(1+[-21 -7 7 21])]	%regular order (dc in middle)
  psubc_ind = zeros(nsubc,1);
  psubc_ind(psubc_idx) = 1;
  [psubc_ind [1:64]'];
  psubc_ind_shifted = fftshift(psubc_ind);
  psubc_idx_shifted = find(psubc_ind_shifted) ;    %[8; 22; 44; 58]

  % pilot symbols to load on the above indices: [1 -1 1 1] * polarity, (corresponding 
  % to [1 1 1 -1] * polarity in natural order)

  pilotsyms = diag([1 -1 1 1]) * ones(4, nsyms);
  polarity = pilot_sc_ext(1:nsyms);
  pilotsyms = pilotsyms * diag(polarity);
  fpsyms = zeros(nsubc, nsyms);
  fpsyms(psubc_idx_shifted, :) = pilotsyms;

  %[fdsyms fpsyms]

  fsyms_data_and_pilot = fdsyms + fpsyms;


  tdsyms = ifft(fsyms_data_and_pilot);

  %verify that the dc components are near-zero
  dc_component = sum(tdsyms)

  %add cyclic prefixes and additional sample for windowing
  prefixes = tdsyms([end-cplength+1:end], :);
  extra_for_windowing = tdsyms(1, :);
  tdsyms_w_cp = [prefixes; tdsyms; extra_for_windowing];

  %window the data
  w = [0.5 ones(1,79) 0.5]';
  tdsyms_w_cp = diag(w) * tdsyms_w_cp;

  row_to_add = [0 tdsyms_w_cp(end,:)];
  tdsyms_w_cp(:,end+1) = zeros(size(tdsyms_w_cp,1), 1);
  tdsyms_w_cp(1,:) = tdsyms_w_cp(1,:) + row_to_add;
  tdsyms_w_cp(end,:) = [];
  size(tdsyms_w_cp)

  %collapse into a single column of samples
  %tdsyms = reshape(tdsyms_w_cp, size(tdsyms_w_cp,1) * nsyms + 1, 1)
  td_data_samples = reshape(tdsyms_w_cp, prod(size(tdsyms_w_cp)), 1);
  td_data_samples = td_data_samples(1:size(tdsyms_w_cp,1) * nsyms + 1);
  size(td_data_samples)
  %pause

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

