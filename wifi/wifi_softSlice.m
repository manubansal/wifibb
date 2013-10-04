% points: input constellation points as a column vector
% nbpsc : no. of coded bits per subcarrier (1 = bpsk, 2 = qpsk, 4 = 16qam, 6 = 64qam)
% nbits : no. of bits in the soft output; 0 will be most confidence 0, 2^nbits - 1 will be most confident 1
% range : points in [-range, range] are mapped to [0, 2^nbits], anything outside is apprpriately saturated
%         Default value of range is 2^(ceil(nbpsc/2))

function softbits = wifi_softSlice(points, nbpsc, nbits, range)
  nsyms = 1;
  %display('size of points:');
  %size(points)
  %pause
  if (prod(size(points)) ~= size(points, 1))
    %error('Input points must form a column vector','Input points must form a column vector, not a matrix');
    nsyms = size(points, 2);
    points = reshape(points, prod(size(points)), 1);
  end

  if (nargin < 4)
    range = 2^(ceil((nbpsc)/2));
  end


  if (nbpsc == 1) %bpsk
      yI = real(points); yQ = imag(points);
      b = yI;

      range = 2;
  elseif (nbpsc == 2) %qpsk
      points = points * (sqrt(2));	%expand out the constellation to regular scale
      yI = real(points); yQ = imag(points);

      b0 = yI;
      b1 = yQ;

      b = [b0 b1];

      range = 2;
  elseif (nbpsc == 4) %16qam
      points = points * (sqrt(10));	%expand out the constellation to regular scale
      yI = real(points); yQ = imag(points);

      b0 = yI;
      b1 = -abs(yI) + 2;
      b2 = yQ;
      b3 = -abs(yQ) + 2;

      b = [b0 b1 b2 b3];

      range = 4;
  elseif (nbpsc == 6) %64qam
      points = points * (sqrt(42));	%expand out the constellation to regular scale
      yI = real(points); yQ = imag(points);

      b0 = yI;
      b1 = -abs(yI) + 4;
      b2 = -abs(abs(yI) - 4) + 2;

      b3 = yQ;
      b4 = -abs(yQ) + 4;
      b5 = -abs(abs(yQ) - 4) + 2;

      b = [b0 b1 b2 b3 b4 b5];

      range = 8;			%maximum constellation value in our dynamic range is 8; anything beyond is saturated
  else
    error('Unknown constellation','I dont know how to soft slice this constellation');
  end

  %b_before_reshaping = b
  %pause
  b = reshape(b', prod(size(b)), 1);	%all bits as a vector
  %b_after_reshaping = b

  %normalize the soft estimates
  scale = 2^(nbits - 1);		%for 8 bits, this is 128, so that we can contain the soft estimates in [-128, 128]
  b = round((b/range + 1) * scale);	%values like in [0, 2^nbits] now, as required by soft vitdec input
  b(find(b >= 2^nbits)) = 2^nbits - 1;
  b(find(b < 0)) = 0;

  %min_b = min(b)
  %max_b = max(b)
  %pause

  b = reshape(b, length(b)/nsyms, nsyms);

  %display('demapped bits after reshaping:');
  %size(b)
  %pause

  softbits = b;
end
