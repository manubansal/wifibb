
%----------------------------------------------------------------------------------------------------------------------------
function [samples count]=util_loadBinaryFile(filename)
%----------------------------------------------------------------------------------------------------------------------------
  fid=fopen(filename,'r');
  [d,count]=fread(fid,[2,inf],'int16', 0, 'ieee-be');
  samples = (d(1,:) + i * d(2,:))/32767;
  samples = samples.';
  %count
  %length(samples)
  fclose(fid);
end
