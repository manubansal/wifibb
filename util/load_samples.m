%>> [samples, n_samples] = load_samples('../wifibb-traces/traces54/usrp-1s.dat','cplx');
%>> [constpoints, n_constpoints] = load_samples('/home/manub/workspace/orsys/app/wifi54/trace/debug/d54mOfdmEq.bho0.bufOutEqualizedPnts.ORILIB_t_Cplx16Buf48.dat', 'cplx');

function [samples, n_samples] = load_samples(samplefilepath, format, little_endian)
  %%%%%%%%%%%%%%%%%%%%%%
  %% read the samples
  %%%%%%%%%%%%%%%%%%%%%%

  if nargin > 1 && strcmp(format,'cplx')
    fid = fopen(samplefilepath, 'r');
    if (nargin < 3)
        little_endian = false;
    end
    if (little_endian)
        [s, n] = fread(fid, inf, 'int16', 0, 'ieee-le');
    else
        [s, n] = fread(fid, inf, 'int16', 0, 'ieee-be');
    end
    fclose(fid);
    s = reshape(s, 2, []).';
    s = s(:,1) + 1i * s(:,2);
    n = n/2;
  end

  if nargin > 1 && strcmp(format,'float32')
    fid = fopen(samplefilepath, 'r');
    [s, n] = fread(fid, inf, 'float');
    fclose(fid);
    s = reshape(s, 2, []).';
    s = s(:,1) + 1i * s(:,2);
    n = n/2;
  end
  
  s(1:10,:)
  samples = s;
  n_samples = n
end
