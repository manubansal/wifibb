%>> [samples, n_samples] = load_samples('../wifibb-traces/traces54/usrp-1s.dat','cplx');
function [samples, n_samples] = load_samples(samplefilepath, format)
  %%%%%%%%%%%%%%%%%%%%%%
  %% read the samples
  %%%%%%%%%%%%%%%%%%%%%%
  fid = fopen(samplefilepath, 'r');
  [s, n] = fread(fid, inf, 'int16');
  fclose(fid);

  if nargin > 1 && strcmp(format,'cplx')
    s = reshape(s, 2, []).';
    s = s(:,1) + i * s(:,2);
    n = n/2;
  end
  
  s(1:10,:)
  samples = s;
  n_samples = n
end
