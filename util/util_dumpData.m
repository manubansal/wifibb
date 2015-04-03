%Dump data into a binary file for scripted comparison/test case generation
%
function util_dumpData(cmp, id, confStr, data)
[DATA_DIR, TRACE_DIR, CDATA_DIR, BDATA_DIR] = setup_paths();
num_strs = regexp(confStr, '\d+', 'match');
rate = str2double(num_strs(1));
[ndbps, rt120, ncbps, nbpsc, nsubc, psubc_idx, d1subc_idx, dsubc_idx] = wifi_parameter_parser(cmp,rate);

if strcmp(id, '')
elseif strcmp(id, 'ltfRxSamples')
    %count_exp = 160;
    count_exp = cmp.ltf_len;
    fprintf(1, 'Dumping ltfRxSamples\n');
    if (sum(size(data(:)) == [count_exp,1]) ~= 2)
        fprintf(1, 'Bad size, skipping\n');
        return;
    end
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.ltfRxSamples.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'int16', 'ieee-be');
    fclose(f);
    if (count ~= count_exp * 2)
        error('something went wrong')
    end
elseif strcmp(id, 'ltfCFOCorrSamples')
    
    count_exp = cmp.ltf_len;
    fprintf(1, 'Dumping ltfCFOCorrSamples\n');
    if (sum(size(data(:)) == [count_exp,1]) ~= 2)
        fprintf(1, 'Bad size, skipping\n');
        return;
    end
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.ltfCFOCorrSamples.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'int16', 'ieee-be');
    fclose(f);
    if (count ~= count_exp * 2)
        error('something went wrong')
    end    
    
elseif strcmp(id, 'plcpMappedSymbols')
    fprintf(1, 'Dumping plcpMappedSymbols\n');
    data = data(:);
    len = length(data);
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.plcpMappedSymbols.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'double', 'ieee-be');
    fclose(f);
    if (count ~= len * 2)
        error('something went wrong')
    end
    
elseif strcmp(id, 'dataMappedSymbols')
    fprintf(1, 'Dumping dataMappedSymbols\n');
    data = data(:);
    len = length(data);
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.dataMappedSymbols.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'double', 'ieee-be');
    fclose(f);
    if (count ~= len * 2)
        error('something went wrong')
    end
    
elseif strcmp(id, 'stfLtfSyncTotal')
    fprintf(1, 'Dumping stfLtfSyncTotal\n');
    data = data(:);
    len = length(data);
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.stfLtfSyncTotal.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'double', 'ieee-be');
    fclose(f);
    if (count ~= len * 2)
        error('something went wrong')
    end
    
elseif strcmp(id, 'dataBits')
    fn = strcat(BDATA_DIR, '/', confStr, '.dataBits.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    fprintf(1, 'Dumping dataBits\n');
    j = 1;
    dump_64 = [0 0 0 0 0 0 0 0];
    for i=0:8:length(data)-1,
        dump_64(j) = bi2de(data(1+i: 8+i)', 'left-msb');
        j = j + 1;
        if (j > ndbps/8)
            j = 1;
            fwrite(f, dump_64, 'double', 'ieee-be');
            dump_64 = [0 0 0 0 0 0 0 0];
        end
    end
    if (j > 1)
        fwrite(f, dump_64, 'double', 'ieee-be');
    end
    fclose(f);
    
elseif strcmp(id, 'plcpPreConvBits')
    fn = strcat(BDATA_DIR, '/', confStr, '.plcpPreConvBits.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    fprintf(1, 'Dumping plcpPreConvBits\n');
    j = 1;
    dump_64 = [0 0 0 0 0 0 0 0];
    for i=0:8:length(data)-1,
        dump_64(j) = bi2de(data(1+i: 8+i), 'left-msb');
        j = j + 1;
        if (j > 8)
            j = 1;
            fwrite(f, dump_64, 'double', 'ieee-be');
            dump_64 = [0 0 0 0 0 0 0 0];
        end
    end
    if (j > 1)
        fwrite(f, dump_64, 'double', 'ieee-be');
    end
    fclose(f);
    
elseif strcmp(id, 'dataPreConvBits')
    fn = strcat(BDATA_DIR, '/', confStr, '.dataPreConvBits.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    fprintf(1, 'Dumping dataPreConvBits\n');
    j = 1;
    dump_64 = [0 0 0 0 0 0 0 0];
    for i=0:8:length(data)-1,
        dump_64(j) = bi2de(data(1+i:8+i)', 'left-msb');
        j = j + 1;
        if (j > ndbps/8)
            j = 1;
            fwrite(f, dump_64, 'double', 'ieee-be');
            dump_64 = [0 0 0 0 0 0 0 0];
        end
    end
    if (j > 1)
        fwrite(f, dump_64, 'double', 'ieee-be');
    end
    fclose(f);
    
elseif strcmp(id, 'plcpConvBits')
    fprintf(1, 'Dumping plcpConvBits\n');
    data = data(:);
    len = length(data);
    fn = strcat(BDATA_DIR, '/', confStr, '.plcpConvBits.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'double', 'ieee-be');
    fclose(f);
    if (count ~= len)
        error('something went wrong')
    end
    
elseif strcmp(id, 'dataConvBits')
    fprintf(1, 'Dumping dataConvBits\n');
    data = data(:);
    len = length(data);
    fn = strcat(BDATA_DIR, '/', confStr, '.dataConvBits.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'double', 'ieee-be');
    fclose(f);
    if (count ~= len)
        error('something went wrong')
    end
    
elseif strcmp(id, 'plcpInterleavedBits')
    fprintf(1, 'Dumping plcpInterleavedBits\n');
    data = data(:);
    len = length(data);
    fn = strcat(BDATA_DIR, '/', confStr, '.plcpInterleavedBits.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'double', 'ieee-be');
    fclose(f);
    if (count ~= len)
        error('something went wrong')
    end
    
elseif strcmp(id, 'dataInterleavedBits')
    fprintf(1, 'Dumping dataInterleavedBits\n');
    data = data(:);
    len = length(data);
    fn = strcat(BDATA_DIR, '/', confStr, '.dataInterleavedBits.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'double', 'ieee-be');
    fclose(f);
    if (count ~= len)
        error('something went wrong')
    end
    
elseif strcmp(id, 'allMappedSymbols')
    fprintf(1, 'Dumping allMappedSymbols\n');
    data = data(:);
    len = length(data);
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.allMappedSymbols.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'double', 'ieee-be');
    fclose(f);
    if (count ~= len * 2)
        error('something went wrong')
    end
    
elseif strcmp(id, 'allOfdmMod')
    fprintf(1, 'Dumping allOfdmMod\n');
    data = data(:);
    len = length(data);
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.allOfdmMod.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'double', 'ieee-be');
    fclose(f);
    if (count ~= len * 2)
        error('something went wrong')
    end
    
    
    
    
elseif strcmp(id, 'plcpBaseSamples')
    count_expected = 80;
    count_expected = 96;
    fprintf(1, 'Dumping plcpBaseSamples\n');
    if (sum(size(data(:)) == [count_expected,1]) ~= 2)
        fprintf(1, 'Bad size, skipping\n');
        return;
    end
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.plcpBaseSamples.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'int16', 'ieee-be');
    fclose(f);
    if (count ~= count_expected * 2)
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
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    %count = fwrite(f, data, 'int16', 'ieee-be');
    count = fwrite(f, data, 'double', 'ieee-be');
    fclose(f);
    if (count ~= 80 * 2)
        error('something went wrong')
    end
    
elseif strcmp(id, 'interleaver48_in')
    fprintf(1, 'Dumping interleaver48_in\n');
    if (sum(size(data(:)) == [48,1]) ~= 2)
        fprintf(1, 'Bad size, skipping\n');
        return;
    end
    data = data(:);
    fn = strcat(BDATA_DIR, '/', confStr, '.interleaver48_in.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'int16', 'ieee-be');
    fclose(f);
    if (count ~= 48)
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
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    %count = fwrite(f, data, 'int16', 'ieee-be');
    count = fwrite(f, data, 'double', 'ieee-be');
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
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    %count = fwrite(f, data, 'int16', 'ieee-be');
    count = fwrite(f, data, 'double', 'ieee-be');
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
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    %count = fwrite(f, data, 'int16', 'ieee-be');
    count = fwrite(f, data, 'double', 'ieee-be');
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
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    %count = fwrite(f, data, 'int16', 'ieee-be');
    count = fwrite(f, data, 'double', 'ieee-be');
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
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    %count = fwrite(f, data, 'int16', 'ieee-be');
    count = fwrite(f, data, 'double', 'ieee-be');
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
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    %data = data
    %pause
    count = fwrite(f, data, 'int8', 'ieee-be');
    fclose(f);
    if (count ~= 48)
        error('something went wrong')
    end
    
elseif strcmp(id, 'dataBaseSamples')
    fprintf(1, 'Dumping dataBaseSamples\n');
    if ~ isvector(data)
        fprintf(1, 'Bad size, skipping\n');
        return;
    end
    len = length(data);
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.dataBaseSamples.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'double', 'ieee-be');
    fclose(f);
    if (count ~= len * 2)
        error('something went wrong')
    end
    
elseif strcmp(id, 'dataCfoCorrected')
    fprintf(1, 'Dumping dataCfoCorrected\n');
    if ~ isvector(data)
        fprintf(1, 'Bad size, skipping\n');
        return;
    end
    len = length(data);
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.dataCfoCorrected.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'double', 'ieee-be');
    fclose(f);
    if (count ~= len * 2)
        error('something went wrong')
    end
    
elseif strcmp(id, 'dataOfdmDemod')
    fprintf(1, 'Dumping ofdmDemodPlcp\n');
    data = data(:);
    len = length(data);
    dr = real(data); dr = dr(:);
    di = imag(data); di = di(:);
    data = [dr di].';
    fn = strcat(BDATA_DIR, '/', confStr, '.dataOfdmDemod.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'double', 'ieee-be');
    fclose(f);
    if (count ~= len * 2)
        error('something went wrong')
    end
    
elseif strcmp(id, 'dataOfdmEq.eqPnts')
    fprintf(1, 'Dumping dataOfdmEq.eqPnts\n');
    data_m = data;
    for jj = 1:size(data_m, 2)
        data = data_m(:,jj);
        if (sum(size(data(:)) == [48,1]) ~= 2)
            fprintf(1, 'Bad size, skipping\n');
            return;
        end
        dr = real(data); dr = dr(:);
        di = imag(data); di = di(:);
        data = [dr di].';
        fn = strcat(BDATA_DIR, '/', confStr, '.dataOfdmEq.eqPnts.mdat');
        fprintf(1, ['Writing to ',fn,'\n']);
        f = fopen(fn, 'a+');
        %count = fwrite(f, data, 'int16', 'ieee-be');
        count = fwrite(f, data, 'double', 'ieee-be');
        fclose(f);
        if (count ~= 48 * 2)
            error('something went wrong')
        end
    end
    
elseif strcmp(id, 'dataDemap')
    fprintf(1, 'Dumping dataDemap\n');
    data = data(:);
    len = length(data);
    fn = strcat(BDATA_DIR, '/', confStr, '.dataDemap.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'int8', 'ieee-be');
    fclose(f);
    if (count ~= len)
        error('something went wrong')
    end
    
elseif strcmp(id, 'dataDepunct')
    fprintf(1, 'Dumping dataDepunct\n');
    data = data(:);
    len = length(data);
    fn = strcat(BDATA_DIR, '/', confStr, '.dataDepunct.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'int8', 'ieee-be');
    fclose(f);
    if (count ~= len)
        error('something went wrong')
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
    fprintf(1, ['Writing to ',fn,'\n']);
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
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    %data = data
    %pause
    count = fwrite(f, data, 'uint8', 'ieee-be');
    fclose(f);
    if (count ~= size(data,1))
        error('something went wrong')
    end
    
elseif strcmp(id, 'dataDescr')
    fprintf(1, 'Dumping dataDescr\n');
    if (size(data,2) ~= 1)
        data = data
        size_data = size(data)
        fprintf(1, 'Bad size, skipping\n');
        return;
    end
    fn = strcat(BDATA_DIR, '/', confStr, '.dataDescr.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'uint8', 'ieee-be');
    fclose(f);
    if (count ~= size(data,1))
        error('something went wrong')
    end
    
elseif strcmp(id, 'dataParsed')
    fprintf(1, 'Dumping dataParsed\n');
    data = hex2dec(data);
    nbytes = length(data)
    fn = strcat(BDATA_DIR, '/', confStr, '.dataParsed.mdat');
    fprintf(1, ['Writing to ',fn,'\n']);
    f = fopen(fn, 'a+');
    count = fwrite(f, data, 'uint8', 'ieee-be');
    fclose(f);
    if (count ~= nbytes)
        error('something went wrong')
    end
else
    error('bad dump option')
end
end
