function util_compare_tx_rx_pkts(msgs_hex, rx_pkts)
  npkts = length(msgs_hex);
  if npkts ~= length(rx_pkts)
    error('Cannot compare: unequal number of pkts to compare')
  end
  npkts_to_compare = npkts

  for ii = 1:npkts
  %for ii = 3
    
    msg_hex = msgs_hex{ii};                     
    msg_dec = hex2dec(msg_hex);                
    %msg_dec = msg_dec(1:15)                   
    %pause                                     
					       
    msg = dec2bin(msg_dec, 8);                 
    msg = fliplr(msg);  %lsb msb flip          
    msg = msg';                                
    msg = reshape(msg, prod(size(msg)), 1);    
    msg = str2num(msg);
    msg_w_crc = wifi_append_crc32(msg);
    size(msg_w_crc)
    a=msg_w_crc;
    b=reshape(a,8,[]).';
    c=bi2de(b);
    d=dec2hex(c,2);
    tx_msg_hex=d;                   %with crc32

    rx_msg_hex = rx_pkts{ii}{1};    %with crc32
    %match = tx_msg_hex == rx_msg_hex;
    diff = dec2hex(sign(abs(hex2dec(tx_msg_hex) - hex2dec(rx_msg_hex))),2);
    %size(rx_msg_hex)
    
    nbytes = length(tx_msg_hex);
    gap = repmat([' '],nbytes,1);
    idx = int2str([0:nbytes-1].');
    
    display(['Comparing tx and rx messages, message #',int2str(ii),' nbytes with crc32:',int2str(nbytes)])
    display(['idx:tx_byte:rx_byte:match(0)/mismatch(1)'])
    [idx gap tx_msg_hex gap rx_msg_hex gap diff]
  end
end
