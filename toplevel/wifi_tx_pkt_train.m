function [td_pkt_samples_16bit msgs_scr signal_rms_linear] = wifi_tx_pkt_train(smp, txp, cmp, msgs_hex, rate, snr, scale, confStr, ch, cplen, use_length_field_for_seq_no)
  %sim_params = default_sim_parameters();
  %tx_params = wifi_tx_parameters();
  %common_params = wifi_common_parameters();
  sim_params = smp;
  tx_params = txp;
  common_params = cmp;

  if (nargin < 6)
    snr = sim_params.snr;
  end

  if (nargin < 7)
    %scale = 1;		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
    %scale = 256;		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
    scale = tx_params.scale;		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
    %scale = 2;		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
    %scale = 4;		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
    %scale = 8;		%factor by which to scale down the samples (so this cuts down the tx gain (linear)
  end

  if (nargin < 9)
    ch = sim_params.ch;
  end

  if (nargin < 10)
    cplen = common_params.cplen;
  end

  if (nargin < 11)
    use_length_field_for_seq_no = false;
  end
  
  n_msgs = length(msgs_hex);

  %zero_prepad_dur_us = 100;		%zero samples of this duration (us) will be prefixed to every packet
  %zero_prepad_dur_us = 10;		%zero samples of this duration (us) will be prefixed to every packet
  zero_prepad_dur_us = sim_params.zero_prepad_dur_us;		%zero samples of this duration (us) will be prefixed to every packet
  zero_postpad_dur_us = sim_params.zero_postpad_dur_us;
  
  %54mbps
  %snr 15	16	17	18
  %ber 0.1412 	0.0275	0	0



  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% preprocess and encode message(s)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  all_td_pkt_samples = {};
  cat_td_pkt_samples = [];
  msgs_scr = {};
  parfor ii = 1:n_msgs
    fprintf(1, 'encoding msg #%d\n', ii);
    msg_hex = msgs_hex{ii};
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
    [samples_f, n_ofdm_syms, databits_i, databits_q, datasyms, td_data_samples, td_pkt_samples, msg_scr] = wifi_tx_chain(smp, txp, cmp, msg, rate, confStr, cplen, use_length_field_for_seq_no, ii - 1);
    %--------------------------------------------------------------------------

    %msgs_scr{end + 1} = msg_scr;
    msgs_scr{ii} = msg_scr;

    %all_td_pkt_samples{end+1} = td_pkt_samples;
    all_td_pkt_samples{ii} = td_pkt_samples;
    cat_td_pkt_samples = [cat_td_pkt_samples; td_pkt_samples];
  end
  %size(cat_td_pkt_samples)

  n_samples = length(cat_td_pkt_samples);
  display(['number of samples in data packet(s): ' num2str(n_samples)]);

  samples_per_us = 1/(10^6*common_params.sample_duration_sec);
  dur_us = n_samples/samples_per_us;
  display(['data packet(s) duration (us):' num2str(dur_us)]);


  signal_rms = rms(cat_td_pkt_samples);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% compute the AWGN noise vector 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if ~isfield(txp, 'APPLY_AWGN') || txp.APPLY_AWGN
    rms_prepad_samples = zeros(samples_per_us * zero_prepad_dur_us - 1, 1) + signal_rms; 	
    %-1 in zero-pad-length is because data portion is generated with one
    %extra sample for windowing

    rms_postpad_samples = zeros(samples_per_us * zero_postpad_dur_us, 1) + signal_rms; 	

    td_pkt_samples = [];
    for ii = 1:n_msgs
      td_pkt_samples = [td_pkt_samples; rms_prepad_samples; ...
	  all_td_pkt_samples{ii}; rms_postpad_samples];
    end

    noisy_td_pkt_samples = wifi_awgn(td_pkt_samples, snr);
    noise_vector = noisy_td_pkt_samples - td_pkt_samples;
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% compose the packet train with pads
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  zero_prepad_samples = zeros(samples_per_us * zero_prepad_dur_us - 1, 1);
  %-1 in zero-pad-length is because data portion is generated with one
  %extra sample for windowing

  zero_postpad_samples = zeros(samples_per_us * zero_postpad_dur_us, 1);


  %td_pkt_samples = [];
  %for ii = 1:n_msgs
  %  td_pkt_samples = [td_pkt_samples; zero_prepad_samples; ...
  %  	all_td_pkt_samples{ii}; zero_postpad_samples];
  %end
  all_td_pkt_samples_with_zeropads = {};
  for ii = 1:n_msgs
    all_td_pkt_samples_with_zeropads{ii} = [zero_prepad_samples; all_td_pkt_samples{ii}; zero_postpad_samples];
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% apply a fading channel to the transmission and vectorize
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if ~isfield(txp,'APPLY_FADING') || (txp.APPLY_FADING && strcmp(txp.FADING_BY,'packet'))
    %% MODEL 1: this one applies a different channel realization to each pkt (default)
    all_td_pkt_samples_faded = wifi_fading_channel(all_td_pkt_samples_with_zeropads, ch);
    td_pkt_samples = [];
    for ii = 1:n_msgs
      td_pkt_samples = [td_pkt_samples; all_td_pkt_samples_faded{ii}];
    end
  elseif txp.APPLY_FADING && strcmp(txp.FADING_BY,'stream')
    %% MODEL 2: this one applies the same channel on the full pkt stream
    all_td_pkt_samples_faded = all_td_pkt_samples_with_zeropads;
    for ii = 1:n_msgs
      td_pkt_samples = [td_pkt_samples; all_td_pkt_samples_faded{ii}];
    end
    td_pkt_samples = wifi_fading_channel(td_pkt_samples, ch);
  else
    %% no fading
    all_td_pkt_samples_faded = all_td_pkt_samples_with_zeropads;
    td_pkt_samples = [];
    for ii = 1:n_msgs
      td_pkt_samples = [td_pkt_samples; all_td_pkt_samples_faded{ii}];
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% add the AWGN noise vector
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if ~isfield(txp, 'APPLY_AWGN') || txp.APPLY_AWGN
    td_pkt_samples = td_pkt_samples + noise_vector;
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %scale samples down by the given input factor to modify tx gain 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  % (this affects quantization noise/quantized snr, although for 
  % reasonable values of awgn snr, snr would be limited by awgn
  % and not by quantization noise. in the case of infinite awgn
  % snr, snr would be limited by quantization noise.)
  td_pkt_samples = td_pkt_samples/scale;
  signal_rms = signal_rms/scale;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %quantize samples
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  td_pkt_samples_16bit = round(td_pkt_samples*32767/1.0*3);
  signal_rms = signal_rms*32767/1.0*3;


  n_samples = length(td_pkt_samples_16bit);
  display(['number of samples in zero-padded packet(s): ' num2str(n_samples)]);

  dur_us = n_samples/samples_per_us;
  display(['zero-padded packet(s) duration (us):' num2str(dur_us)]);

  disp('displaying the maximum real and imaginary components in generated packet');
  disp('make sure they are not over 32767, the maximum permissible 16 bit value');

  max_real=max(real(td_pkt_samples_16bit));
  max_imag=max(imag(td_pkt_samples_16bit));
  fprintf('max_real: %d, max_imag: %d\n', [max_real max_imag]);

  if (max_real > 32767 || max_imag > 32767)
    error('max exceeded','maximum value of a sample exceeds dynamic range; try increasing the scale value.');
  end
  
  signal_rms_linear = signal_rms;
end
