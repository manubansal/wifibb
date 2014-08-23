
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions to write binary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function util_writeSamplesToBinaryFile(filename, samples, len)
  if (nargin == 2)
    len = length(samples)
  end
  fid=fopen(filename,'w');
  rr=real(samples(1:len));
  ii=imag(samples(1:len));
  ri = [rr ii].';
  %display('writing the following as interleaved 16bit signed integers in column order to binary file:')
  %ri
  fwrite(fid, ri, 'int16', 'ieee-be');
  fclose(fid);
end
