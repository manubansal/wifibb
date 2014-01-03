%this frame is real data from a real NIC, as displayed in wireshark last 4
%bytes are the FCS value
%c4 00 94 00 14 10 9f eb 65 8c f3 35 a3 7d

msg_w_crc=[...
'c4';'00';'94';'00';'14';'10';'9f'
'eb';'65';'8c';'f3';'35';'a3';'7d']
mc = msg_w_crc;
m = mc(1:end-4,:);
c = mc(end-3:end,:);
co = c';
co = co(:)';

nbytes = length(m)

mb = [];
for i = 1:nbytes
  byte = m(i,:)
  bb = de2bi(hex2dec(byte),8);			%lsb-first
  mb = [mb bb];
end

cc = wifi_bit_crc32_v2(mb);	%higher order bit is first in the output

%% the following reverses the bit order in each byte of the crc output
%% (this takes us from msb-first to lsb-first convention.)
%bit order reversal - start
ccbin = cc;
ccbinbytes = reshape(cc,8,[]);	%each col is a byte, msb on top, lsb on bottom
ccbinbytes = ccbinbytes';	%each row is byte, msb on left, lsb on right
ccbinbytes = fliplr(ccbinbytes);%each row is byte, msb on right, lsb on left (lsb-first)
ccbinbytes = ccbinbytes';
cc = ccbinbytes(:);
%%%bit order reversal - end

cc = reshape(cc, 4, []);
cc = cc';
cc = dec2hex(bi2de(cc, 'left-msb'))';

co
cc
