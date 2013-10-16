%Dump data into a binary file for scripted comparison/test case generation
%
function util_dumpData(id, data)
  [DATA_DIR, TRACE_DIR, CDATA_DIR, BDATA_DIR] = setup_paths()
  [ndbps, rt120, ncbps, nbpsc, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameters(0)

  if strcmp(id, 'ofdmDemodPlcp')
    fprintf(1, 'Dumping ofdmDemodPlcp\n');
    if (sum(size(data(:)) == [48,1]) ~= 2)
      fprintf(1, 'Bad size, skipping\n');
      return;
    end
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/plcpOfdmDemod.mdat');
    fprintf(1, ['Writing to ',fn]);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'int16', 'ieee-be');
    fclose(f);
    if (count ~= 48 * 2)
      error('something went wrong')
    end
  else
    error('bad dump option')
  end
end
