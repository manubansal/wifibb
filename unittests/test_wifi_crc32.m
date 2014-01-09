function crc_val = test_wifi_crc32()
	%test1();
	%test2();
	%test3();
	%test4();
	%test5();
	crc_val = test6();
end

function crc_val = test6()
  msg_no_crc = ['FF'];
  [msg_bin_lin msg_len] = util_hexToBinLin(msg_no_crc);
  crc_val = wifi_bit_crc32(msg_bin_lin)
  %crc_hex = crc_val
end


%tests for TI implementation debugging for a real wifi packet
function test5()
  nbytes = 169;		%includes crc bytes but not service bytes

  load(strcat(getenv('TRACE_DIR'), '/match/descr_out.txt'));
  b = descr_out(:,2:end);

  %load('../wifibb-traces/match/descr_ref.txt');
  %b = descr_ref(:,2:end);

  b = b';
  b = reshape(b, prod(size(b)), 1);
  b(1:64,:)

  %remove service field
  b = b(17:end,:);

  %keep the relevant length
  b = b(1:(nbytes * 8),:);

  %lcrc = 1;	%no. of bytes under crc
  for lcrc=1:3:nbytes
	  lcrc = lcrc
	  d = b(1:(lcrc*8),:);
	  crcVal = wifi_bit_crc32(d);
	  crcVal = dec2hex(bin2dec(num2str(crcVal)'),8)
  end

  unique_value_expected = '38FB2284'
end

%same test as test3 but on a random input.
function test4()
	nbytes = 23;
	dec_msg = randint(nbytes, 1, [0,255]);
	hex_msg = dec2hex(dec_msg, 2)
	bin_msg_tx = util_hexToBinLin(hex_msg);
	crc_val_tx = wifi_bit_crc32(bin_msg_tx);
	bin_msg_tx_w_crc = [bin_msg_tx; crc_val_tx];
	crc_val_rx = wifi_bit_crc32(bin_msg_tx_w_crc);
	crc_val_rx_c = 1 - crc_val_rx;


	%x31 + x30 + x26 + x25 + x24 + x18 + x15 + x14 + x12 + x11 + x10 + x8 + x6 + x5 + x4 + x3 + x + 1
	ref_rx_rem_idx = 32 - [31 30 26 25 24 18 15 14 12 11 10 8 6 5 4 3 1 0];
	ref_rx_rem = zeros(32, 1);
	ref_rx_rem(ref_rx_rem_idx) = 1;

	%hex value of the unique remainder
	unique_remainder_hex = dec2hex(bin2dec(num2str(ref_rx_rem)'),8)			% C704DD7B
	unique_remainder_hex_c = dec2hex(bin2dec(num2str(1 - ref_rx_rem)'),8)		% 38FB2284

	display('verifying unique remainder technique to verify rx crc validity');
	[crc_val_tx crc_val_rx_c ref_rx_rem (crc_val_rx_c - ref_rx_rem)]
	match = (sum(abs(crc_val_rx_c - ref_rx_rem)) == 0)
end
%Thus, consider the received data including the last four bytes containing the received crc value (not the crc of the
%received data). On this received data, compute the crc. That value will always be 38FB2284 in the absence of errors.


%verifying the following from 802.11:
%"At the receiver, the initial remainder is preset to all ones and the serial incoming bits of the calculation fields
%and FCS, when divided by G(x), results in the absence of transmission errors, in a unique nonzero remainder
%value. The unique remainder value is the polynomial:
%x31 + x30 + x26 + x25 + x24 + x18 + x15 + x14 + x12 + x11 + x10 + x8 + x6 + x5 + x4 + x3 + x + 1
%"
function test3()
	hex_crc = ['9F';'24';'65';'6C'];

	hex_msg = ['FF';'00'; 'FF'; '00'; ...
			%'00';'00';'00';'00'];	%last 4 bytes are the input crc, rest of the prefix is the message
			hex_crc];


	[crc_val crcValid] = wifi_crc32(hex_msg)
	[crc_val util_hexToBinLin(hex_crc)]

	%x31 + x30 + x26 + x25 + x24 + x18 + x15 + x14 + x12 + x11 + x10 + x8 + x6 + x5 + x4 + x3 + x + 1
	ref_rx_rem_idx = 32 - [31 30 26 25 24 18 15 14 12 11 10 8 6 5 4 3 1 0];
	ref_rx_rem = zeros(32, 1);
	ref_rx_rem(ref_rx_rem_idx) = 1;

	%compute crc treating the appended crc value as part of data
	crc_val_rx = wifi_bit_crc32(util_hexToBinLin(hex_msg))
	crc_val_rx_c = 1 - crc_val_rx;

	display('verifying unique remainder technique to verify rx crc validity');
	[crc_val_rx_c ref_rx_rem (crc_val_rx_c - ref_rx_rem)]
	match = (sum(abs(crc_val_rx_c - ref_rx_rem)) == 0)


end

%wifi_bit_crc32 can compute crc of any number of input bytes/bits, and takes input as a bit vector without crc at the end
function test2()
  msg_no_crc = ['FF'];
  [msg_bin_lin msg_len] = util_hexToBinLin(msg_no_crc);
  crc_val = wifi_bit_crc32(msg_bin_lin)
end

%wifi_crc32 requires at least 32 bits in the input message and expect last four bytes to be the crc value itself
function test1()

	%hex_msg = ['FF';'00';'00';'00';'00'];	%last 4 bytes are the input crc, rest of the prefix is the message

	%1111 1001|0010 0100|1010 0110|0011 0110 - bit order crc value, need to express each byte so that
	%					  the oldest bit is the lsb in that byte
	%1001 1111|0010 0100|0110 0101|0110 1100 - converted to byte-wise representation by writing msb as
	%					  in it's proper position

	%hex_crc = ['FC';'92';'53';'63'];
	hex_crc = ['9F';'24';'65';'6C'];

	hex_msg = ['FF';'00'; 'FF'; '00'; ...
			%'00';'00';'00';'00'];	%last 4 bytes are the input crc, rest of the prefix is the message
			hex_crc];


	[crc_val crcValid] = wifi_crc32(hex_msg)
	[crc_val util_hexToBinLin(hex_crc)]

end


%%Uint8 gCrcCodecInputData[128] = {0x0A,
%		hex_msg = {0x0A,
%                                 0x75,
%                                 0xEC,
%                                 0x3C,
%                                 0xE8,
%                                 0x3A,
%                                 0xB7,
%                                 0xD2,
%                                 0xFE,
%                                 0x4F,
%                                 0xE2,
%                                 0x31,
%                                 0x3C,
%                                 0x17,
%                                 0x04,
%                                 0x65,
%                                 0x19,
%                                 0xAD,
%                                 0x6B,
%                                 0x00,
%                                 0xC1,
%                                 0x06,
%                                 0xC7,
%                                 0xD8,
%                                 0xC0,
%                                 0xB0,
%                                 0x37,
%                                 0xBC,
%                                 0xD1,
%                                 0xE7,
%                                 0x7D,
%                                 0x59,
%                                 0x5C,
%                                 0xAE,
%                                 0xD2,
%                                 0xE2,
%                                 0x12,
%                                 0x47,
%                                 0x5C,
%                                 0x9B,
%                                 0x3E,
%                                 0x5E,
%                                 0xB3,
%                                 0x8F,
%                                 0x18,
%                                 0xEE,
%                                 0xB5,
%                                 0x71,
%                                 0x1B,
%                                 0xED,
%                                 0xDF,
%                                 0xE4,
%                                 0x00,
%                                 0xAB,
%                                 0x3D,
%                                 0xA0,
%                                 0xE4,
%                                 0xF5,
%                                 0x9F,
%                                 0x64,
%                                 0x5F,
%                                 0x1A,
%                                 0xAD,
%                                 0x15,
%                                 0xEE,
%                                 0x19,
%                                 0x9C,
%                                 0xEC,
%                                 0x45,
%                                 0x84,
%                                 0x6A,
%                                 0x64,
%                                 0x00,
%                                 0xD0,
%                                 0x14,
%                                 0x4A,
%                                 0x9C,
%                                 0x80,
%                                 0xF2,
%                                 0x5F,
%                                 0x44,
%                                 0x3A,
%                                 0xB6,
%                                 0x3F,
%                                 0x6E,
%                                 0xD6,
%                                 0x49,
%                                 0x90,
%                                 0xAC,
%                                 0x87,
%                                 0xD1,
%                                 0x55,
%                                 0x4D,
%                                 0xEA,
%                                 0x9B,
%                                 0xB7,
%                                 0x0E,
%                                 0xA0,
%                                 0x41,
%                                 0x37,
%                                 0x22,
%                                 0x62,
%                                 0x28,
%                                 0x99,
%                                 0xEE,
%                                 0x76,
%                                 0xBC,
%                                 0xF7,
%                                 0x6A,
%                                 0x2B,
%                                 0x71,
%                                 0xB1,
%                                 0x6E,
%                                 0xF1,
%                                 0x64,
%                                 0x6F,
%                                 0x95,
%                                 0xF0,
%                                 0x3A,
%                                 0x40,
%                                 0x36,
%                                 0xAB,
%                                 0x2F,
%                                 0x05,
%                                 0x41,
%                                 0xFE,
%                                 0xC8,
%                                 0x0D};
%
