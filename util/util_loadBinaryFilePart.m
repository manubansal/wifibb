
%----------------------------------------------------------------------------------------------------------------------------
function [samples count]=util_loadBinaryFilePart(filename, ns, skip)
%----------------------------------------------------------------------------------------------------------------------------
  fid=fopen(filename,'r');
  disp(strcat('opening file ', filename))
  st = fseek(fid, 4*skip, 'bof');
  if (st < 0)
    display('Could not seek file to skip samples');
    error('SeekError','SeekError');
  end
  if (ns == 0)
    [d,count]=fread(fid,[2,inf],'int16', 0, 'ieee-be');
  else
    [d,count]=fread(fid,[2,ns],'int16', 0, 'ieee-be');
  end
  samples = (d(1,:) + i * d(2,:))/32767;
  samples = samples.';
  %count
  %length(samples)
  fclose(fid);
end
