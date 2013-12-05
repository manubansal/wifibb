%Dump data into a binary file for scripted comparison/test case generation
%
function util_dumpData(id, confStr, data)
  [DATA_DIR, TRACE_DIR, CDATA_DIR, BDATA_DIR] = setup_paths()
  [ndbps, rt120, ncbps, nbpsc, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameters(0)

  if strcmp(id, '')
  elseif strcmp(id, 'plcpBaseSamples')
    fprintf(1, 'Dumping plcpBaseSamples\n');
    if (sum(size(data(:)) == [80,1]) ~= 2)
      fprintf(1, 'Bad size, skipping\n');
      return;
    end
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.plcpBaseSamples.mdat');
    fprintf(1, ['Writing to ',fn]);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'int16', 'ieee-be');
    fclose(f);
    if (count ~= 80 * 2)
      error('something went wrong')
    end
  elseif strcmp(id, 'plcpCfoCorrected')
    fprintf(1, 'Dumping plcpCfoCorrected\n');
    if (sum(size(data(:)) == [80,1]) ~= 2)
      fprintf(1, 'Bad size, skipping\n');
      return;
    end
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.plcpCfoCorrected.mdat');
    fprintf(1, ['Writing to ',fn]);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'int16', 'ieee-be');
    fclose(f);
    if (count ~= 80 * 2)
      error('something went wrong')
    end
  elseif strcmp(id, 'plcpOfdmDemod')
    fprintf(1, 'Dumping ofdmDemodPlcp\n');
    if (sum(size(data(:)) == [48,1]) ~= 2)
      fprintf(1, 'Bad size, skipping\n');
      return;
    end
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.plcpOfdmDemod.mdat');
    fprintf(1, ['Writing to ',fn]);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'int16', 'ieee-be');
    fclose(f);
    if (count ~= 48 * 2)
      error('something went wrong')
    end
  elseif strcmp(id, 'plcpOfdmEq.eqPnts')
    fprintf(1, 'Dumping plcpOfdmEq.eqPnts\n');
    if (sum(size(data(:)) == [48,1]) ~= 2)
      fprintf(1, 'Bad size, skipping\n');
      return;
    end
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.plcpOfdmEq.eqPnts.mdat');
    fprintf(1, ['Writing to ',fn]);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'int16', 'ieee-be');
    fclose(f);
    if (count ~= 48 * 2)
      error('something went wrong')
    end

  elseif strcmp(id, 'plcpOfdmEq.channeli')
    fprintf(1, 'Dumping plcpOfdmEq.channeli\n');
    if (sum(size(data(:)) == [64,1]) ~= 2)
      fprintf(1, 'Bad size, skipping\n');
      return;
    end
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.plcpOfdmEq.channeli.mdat');
    fprintf(1, ['Writing to ',fn]);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'int16', 'ieee-be');
    fclose(f);
    if (count ~= 64 * 2)
      error('something went wrong')
    end

  elseif strcmp(id, 'plcpOfdmEq.channel_dsubc')
    fprintf(1, 'Dumping plcpOfdmEq.channel_dsubc\n');
    if (sum(size(data(:)) == [48,1]) ~= 2)
      fprintf(1, 'Bad size, skipping\n');
      return;
    end
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.plcpOfdmEq.channel_dsubc.mdat');
    fprintf(1, ['Writing to ',fn]);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'int16', 'ieee-be');
    fclose(f);
    if (count ~= 48 * 2)
      error('something went wrong')
    end

  elseif strcmp(id, 'plcpOfdmEq.channel_psubc')
    fprintf(1, 'Dumping plcpOfdmEq.channel_psubc\n');
    if (sum(size(data(:)) == [4,1]) ~= 2)
      fprintf(1, 'Bad size, skipping\n');
      return;
    end
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.plcpOfdmEq.channel_psubc.mdat');
    fprintf(1, ['Writing to ',fn]);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'int16', 'ieee-be');
    fclose(f);
    if (count ~= 4 * 2)
      error('something went wrong')
    end

  elseif strcmp(id, 'plcpDemap')
    fprintf(1, 'Dumping plcpDemap\n');
    if (sum(size(data(:)) == [48,1]) ~= 2)
      fprintf(1, 'Bad size, skipping\n');
      return;
    end
    fn = strcat(BDATA_DIR, '/', confStr, '.plcpDemap.mdat');
    fprintf(1, ['Writing to ',fn]);
    f = fopen(fn, 'a+');
    %data = data
    %pause
    count = fwrite(f, data, 'int8', 'ieee-be');
    fclose(f);
    if (count ~= 48)
      error('something went wrong')
    end

  elseif strcmp(id, 'dataOfdmEq.eqPnts')
    fprintf(1, 'Dumping dataOfdmEq.eqPnts\n');
    size_data = size(data)
    pause
    data_m = data;
    for jj = 1:size(data_m, 2)
      data = data_m(:,jj)
      if (sum(size(data(:)) == [48,1]) ~= 2)
	fprintf(1, 'Bad size, skipping\n');
	return;
      end
      dr = real(data); dr = dr(:);
      di = imag(data); di = di(:);
      data = [dr di].';
      fn = strcat(BDATA_DIR, '/', confStr, '.dataOfdmEq.eqPnts.mdat');
      fprintf(1, ['Writing to ',fn]);
      f = fopen(fn, 'a+');
      %count = fwrite(f, data, 'int16', 'ieee-be');
      count = fwrite(f, data, 'double', 'ieee-be');
      fclose(f);
      if (count ~= 48 * 2)
	error('something went wrong')
      end
    end

  elseif strcmp(id, 'dataVitdecChunks')
    fprintf(1, 'Dumping dataVitdecChunks\n');
    if (size(data,2) ~= 1)
      data = data
      size_data = size(data)
      fprintf(1, 'Bad size, skipping\n');
      return;
    end
    fn = strcat(BDATA_DIR, '/', confStr, '.dataVitdecChunks.mdat');
    fprintf(1, ['Writing to ',fn]);
    f = fopen(fn, 'a+');
    %data = data
    %pause
    count = fwrite(f, data, 'uint8', 'ieee-be');
    fclose(f);
    if (count ~= size(data,1))
      error('something went wrong')
    end

  elseif strcmp(id, 'dataVitdec')
    fprintf(1, 'Dumping dataVitdec\n');
    if (size(data,2) ~= 1)
      data = data
      size_data = size(data)
      fprintf(1, 'Bad size, skipping\n');
      return;
    end
    fn = strcat(BDATA_DIR, '/', confStr, '.dataVitdec.mdat');
    fprintf(1, ['Writing to ',fn]);
    f = fopen(fn, 'a+');
    %data = data
    %pause
    count = fwrite(f, data, 'uint8', 'ieee-be');
    fclose(f);
    if (count ~= size(data,1))
      error('something went wrong')
    end
  else
    error('bad dump option')
  end
end
