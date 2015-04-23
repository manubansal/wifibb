
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions to write txt 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function util_writeSamplesToTextFile(filename, samples)
  fid=fopen(filename,'a');
  for ii = 1:length(samples)
  %    save('preamble_oversampled.txt','-ascii','pciri');
      fprintf(fid,'{%4d, %4d},\n',real(samples(ii)),imag(samples(ii)));
  end
  fclose(fid);
end
