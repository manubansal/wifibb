
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions to write binary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function util_writeSamplesToBinaryFile(filename, samples, len, little_endian)
  if (nargin == 2)
    len = length(samples)
  end
  if nargin < 4
    little_endian = false
  end
  fid=fopen(filename,'a');
  rr=real(samples(1:len));
  ii=imag(samples(1:len));
  ri = [rr ii].';
  %display('writing the following as interleaved 16bit signed integers in column order to binary file:')
  %ri
  if little_endian
  fwrite(fid, ri, 'int16', 'ieee-le');
  else
  fwrite(fid, ri, 'int16', 'ieee-be');
  end
  fclose(fid);
end
