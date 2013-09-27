function [parsed_data frame_type ber crcValid] = wifi_parse_phy_payload(databytes)
  %databytes = reshape(databits, 8, length(databits));
  ftype.data 	= 0;
  ftype.ack 	= 1;
  ftype.unknown = 2;

  ber = -1;
  crcValid = false;

  %m = 2.^(7:-1:0)';	%oldest is msb
  m = 2.^(0:7)';	%oldest is lsb

  %databytes_dec = sum(diag(m) * databytes)
  b = (diag(m) * databytes);
  databytes_dec = sum(b);
  databytes_hex = dec2hex(databytes_dec, 2);

  parsed_data = databytes_hex;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% data or ack
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  frame_control = databytes_hex(1:2,:);


  if (frame_control == ['08';'00'])
    frame_type = ftype.data;
  %elseif ((hex2dec(frame_control) == hex2dec(['d4';'00'])))
  %elseif (sum(frame_control == ['d4';'00']) == 4 || sum(frame_control == ['D4';'00']) == 4)
  elseif (hex2dec(frame_control(1,:)) == hex2dec('d4') && hex2dec(frame_control(2,:)) == 0)
    frame_type = ftype.ack;
  else
    frame_type = ftype.unknown
    pause
  end

  if (frame_type == ftype.data)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% data processing
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %length of 80211 header is variable, depending on frame type
    %as found from the frame_control field. we know we are only
    %looking at 24B headers though for our kind of data.
    header80211 = databytes_hex(1:24,:);
    display('header80211:');
    util_printHexOctets(header80211);

    headerLLC = databytes_hex((24+1):(24+8),:);
    %util_printHexOctets(headerLLC);

    headerIP = databytes_hex((32+1):(32+20),:);

    headerUDP = databytes_hex((52+1):(52+8),:);

    udp_length_field = headerUDP([5 6],:);
    udp_length_hex = [udp_length_field(1,:) udp_length_field(2,:)];
    udp_length_val = hex2dec(udp_length_hex);
    udp_data_length_val = udp_length_val - 8;

    data_msg_length = 100;	%known from tx
    data_seq_no_length = udp_data_length_val - data_msg_length;
    %pause

    msg = databytes_hex((60+data_seq_no_length+1):(60+data_seq_no_length+data_msg_length),:);
    msg_under_crc = databytes_hex((1):(60+data_seq_no_length+data_msg_length),:);
    rx_crc = databytes_hex(end-4+1:end, :);
    %rx_crc = databytes_hex(60+data_seq_no_length+data_msg_length+1:60+data_seq_no_length+data_msg_length+4, :);
    %pause

    [ber crcValid] = compareDataFrameData(msg, msg_under_crc, rx_crc);
    %pause

  elseif (frame_type == ftype.ack)
    header80211 = databytes_hex(1:14,:);
    display('header80211:');
    util_printHexOctets(header80211);

    %rx_data_no_fcs = databytes(:,1:10);
    %[ber] = compareAckFrameData(rx_data_no_fcs);
    %[ber crcValid] = compareAckFrameData(databytes)
    [ber crcValid] = compareAckFrameData(databytes_hex);
    %pause
  end
end

function [ber crcValid] = compareDataFrameData(rx_data, rx_data_under_crc, rx_crc)
  true_data = repmat(['a';'b';'c';'d'],25,1);
  %pause
  true_data_dec_ascii = int8(true_data);
  true_data_bin = dec2bin(true_data_dec_ascii, 8) == '1';
  true_data_bin = reshape(fliplr(true_data_bin)',800,1);
  %pause

  rx_data_no_crc = rx_data(1:100,:);
  [rx_data_bin n_bits] = util_hexToBinLin(rx_data_no_crc);

  n_bit_err = sum(abs(rx_data_bin - true_data_bin));

  ber = n_bit_err/n_bits;
  %crcValid = false;
  %size(rx_data_no_crc)
  %size(rx_crc)
  %%rx_data_with_crc = [rx_data_no_crc; rx_crc];
  %%[crc_val crcValid] = wifi_crc32(rx_data_with_crc);
  size_rx_data_under_crc = size(rx_data_under_crc)
  rx_data_under_crc_with_crc = [rx_data_under_crc; rx_crc];
  [crc_val crcValid] = wifi_crc32(rx_data_under_crc_with_crc);
  %pause

  %[true_data_bin rx_data_bin  true_data_bin - rx_data_bin]
  %pause
end

function [ber crcValid] = compareAckFrameData(rx_data)
  %excluding crc
  ack_true_data = ['d4';'00';'00';'00';'00';'22';'b0';'e1';'25';'16'];
  ack_true_crc = ['9a';'aa';'04';'a7'];
  ack_true_data_dec = hex2dec(ack_true_data);
  ack_true_data_bin = dec2bin(ack_true_data_dec, 8);
  %flip lsb msb order
  ack_true_data_bin = fliplr(ack_true_data_bin);
  ack_true_data_bits_as_bytes = ack_true_data_bin';
  %size(ack_true_data_bits_as_bytes)
  %whos
  ack_true_data_bits_as_bytes = (ack_true_data_bits_as_bytes == '1');

  %whos
  %pause
  %rx_data_no_fcs = rx_data(:,1:10);
  rx_data_hex_no_fcs = rx_data(1:10,:);
  rx_data_no_fcs = util_hexToBinLin(rx_data_hex_no_fcs);
  rx_data_no_fcs_bits_as_bytes = reshape(rx_data_no_fcs, 8, 10);
  %n_bit_err = sum(sum(rx_data_no_fcs ~= ack_true_data_bits_as_bytes));
  n_bit_err = sum(sum(rx_data_no_fcs_bits_as_bytes ~= ack_true_data_bits_as_bytes));
  ber = n_bit_err/prod(size(ack_true_data_bits_as_bytes));
  %pause
  %rx_data_no_fcs = rx_data_no_fcs
  %ack_true_data_bits_as_bytes = ack_true_data_bits_as_bytes
  %pause
  %crcValid = false;
  %size(rx_data)
  %rx_data
  %pause
  [crc_val crcValid] = wifi_crc32(rx_data);
end
