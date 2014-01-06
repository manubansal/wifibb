
% THIS ONE WORKS %
% src: http://www.cs.washington.edu/homes/dhalperi/useful.html
%-------------------------------------------------------------------------------
function ret = wifi_bit_crc32(bits)
%-------------------------------------------------------------------------------
  %display('crc32');
  poly = [1 de2bi(hex2dec('EDB88320'), 32)]';
  bits = bits(:);

  % Flip first 32 bits
  bits(1:32) = 1 - bits(1:32);

  % Add 32 zeros at the back
  bits = [bits; zeros(32,1)];

  remarray = [];

  % Initialize remainder to 0
  rem = zeros(32,1);
  % Main computation loop for the CRC32
  for i = 1:length(bits)
      rem = [rem; bits(i)]; %#ok<AGROW>
      if rem(1) == 1
	  rem = mod(rem + poly, 2);
      end
      rem = rem(2:33);
      remarray = [remarray rem];
  end

  % Flip the remainder before returning it
  ret = 1 - rem;
end
