% nbits: number of bits in the soft-bit dynamic range (softbit is in [0, 2^nbits - 1]) 
function depunctured_softbits = wifi_softDepuncture(softbits, nbits, coderateTimes120)

  if (prod(size(softbits)) ~= size(softbits, 1))
    error('Input points must form a column vector','Input points must form a column vector, not a matrix');
  end

  code = coderateTimes120;
  dummy = 2^(nbits - 1);

  if (code == 60)	%rate 1/2, nothing to do
    depunctured_softbits = softbits;
  elseif (code == 80)	%rate 2/3
    bits = reshape(softbits, 3, length(softbits)/3);
    bits(4, :) = dummy;
    depunctured_softbits = reshape(bits, prod(size(bits)), 1);
  elseif (code == 90)	%rate 3/4
    bits = reshape(softbits, 4, length(softbits)/4);
    bits(6, :) = bits(4, :);
    bits([4 5], :) = dummy;
    depunctured_softbits = reshape(bits, prod(size(bits)), 1);
  else
    error('Unknown code rate','I dont know how to depuncture this code rate');
  end
end
