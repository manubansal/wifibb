%works for wifi%
function ret = crc32_value_from_hex_msg(hex_msg)
  [msg_bin_lin msg_len] = util_hexToBinLin(hex_msg);

  bits = msg_bin_lin;

  poly = [1 de2bi(hex2dec('EDB88320'), 32)]'
  %pause
  bits = bits(:);

  % Flip first 32 bits
  bits(1:32) = 1 - bits(1:32);
  % Add 32 zeros at the back
  bits = [bits; zeros(32,1)];

  % Initialize remainder to 0
  rem = zeros(32,1);
  % Main computation loop for the CRC32
  for i = 1:length(bits)
      rem = [rem; bits(i)]; %#ok<AGROW>
      if rem(1) == 1
	  rem = mod(rem + poly, 2);
      end
      rem = rem(2:33);
  end

  % Flip the remainder before returning it
  ret = 1 - rem;
end
