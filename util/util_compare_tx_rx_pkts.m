function util_compare_tx_rx_pkts(msgs_hex, rx_pkts, msgs_scr)
  npkts = length(msgs_hex);
  if npkts ~= length(rx_pkts)
    error('Cannot compare: unequal number of pkts to compare')
  end

  for ii = 1:npkts
    rx_msg_hex = rx_pkts{ii}{1};    %with crc32
    rx_crcValid = rx_pkts{ii}{3};
    nbytes = length(rx_msg_hex);
    
    %compare only if rx pkt's crc is not valid
    if rx_crcValid == 0
      display(['Comparing tx and rx messages for message #',int2str(ii),' because rx crc does not match.'])
      display(['nbytes with crc32:',int2str(nbytes)])
      display('Press any key to continue...')
      pause
      msg_hex = msgs_hex{ii};                     
      msg_dec = hex2dec(msg_hex);                
						 
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

      diff = dec2hex(sign(abs(hex2dec(tx_msg_hex) - hex2dec(rx_msg_hex))),2);
      
      gap = repmat([' '],nbytes,1);
      idx = int2str([0:nbytes-1].');
      
      display(['idx:tx_byte:rx_byte:match(0)/mismatch(1)'])
      [idx gap tx_msg_hex gap rx_msg_hex gap diff]

      %%display(['Comparing scrambled tx msg with scrambled rx msg'])
      %%rx_msg_scr = rx_pkts{ii}{4};	%rx_data_bits_dec
      %%tx_msg_scr = msgs_scr{ii}(:);
      %%tx_msg_scr = tx_msg_scr(1:length(rx_msg_scr));    %to drop tail and pad
      %%d = tx_msg_scr - rx_msg_scr;
      %%i = [0:length(tx_msg_scr)-1].';
      %%[i tx_msg_scr rx_msg_scr d]
    end
  end
end
