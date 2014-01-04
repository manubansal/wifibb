%this frame is real data from a real NIC, as displayed in wireshark last 4
%bytes are the FCS value
%c4 00 94 00 14 10 9f eb 65 8c f3 35 a3 7d

%msg_w_crc=[...
%'c4';'00';'94';'00';'14';'10';'9f'
%'eb';'65';'8c';'f3';'35';'a3';'7d'];

msg_w_crc=[...
'04'; '00'; '00'; '00'; '00'];

%msg_w_crc=[...
%'04';'29';'D4';'F6';'AB';'00';'00';'00';'00'];

msg_w_crc=[...
'04';'94';'2B';'6F';'D5';'00';'00';'00';'00'];

mc = msg_w_crc;
m = mc(1:end-4,:);
c = mc(end-3:end,:);
co = c';
co = co(:)';

nbytes = size(m, 1)

mb = [];
for i = 1:nbytes
  byte = m(i,:);
  bb = de2bi(hex2dec(byte),8);			%lsb-first
  mb = [mb bb];
end

cc = wifi_bit_crc32_v2(mb);	%higher order bit is first in the output
ccx = 1 - cc;			%cc without ones complement
ccbin = cc;


ccx = reshape(ccx, 4, []);
ccx = ccx';
ccx = dec2hex(bi2de(ccx, 'left-msb'))';


cc = reshape(ccbin, 4, []);
cc = cc';
cc = dec2hex(bi2de(cc, 'left-msb'))';


%% the following reverses the bit order in each byte of the crc output
%% (this takes us from msb-first to lsb-first convention.)
%bit order reversal - start
ccbinbytes = reshape(ccbin,8,[]);	%each col is a byte, msb on top, lsb on bottom
ccbinbytes = ccbinbytes';	%each row is byte, msb on left, lsb on right
ccbinbytes = fliplr(ccbinbytes);%each row is byte, msb on right, lsb on left (lsb-first)
ccbinbytes = ccbinbytes';
ccr = ccbinbytes(:);
%%%bit order reversal - end

ccr = reshape(ccr, 4, []);
ccr = ccr';
ccr = dec2hex(bi2de(ccr, 'left-msb'))';

cc_original_reference_ = co
cc_wo_bitreord_wo_xor_ = ccx
cc_wout_bit_reordering = cc
cc_with_bit_reordering = ccr
