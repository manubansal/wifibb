
%----------------------------------------------------------------------------------------------------------------------------
function bytes = bitsToBytes(bit_vector)
%----------------------------------------------------------------------------------------------------------------------------
  l = length(bit_vector);
  if (mod(l,8) ~= 0)
	  error('number of bits not a multiple of 8','number of bits not a multiple of 8');
  end
  nBytes = l/8;
  bytes = reshape(bit_vector, 8, nBytes);	%each column is a byte, msb at the top
  pv = 2.^[7:-1:0];
  %pv = power(2,pv)
  %pv = diag(pv)
  %bytes
  decBytes = pv * bytes;
  bytes = dec2bin(decBytes);
end
