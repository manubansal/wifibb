function util_writeSamples(td_pkt_samples_16bit, confStr)
    %%%%%%%%%%%%%%%%%%%
    [DATA_DIR, TRACE_DIR, CDATA_DIR, BDATA_DIR] = setup_paths();
    dt = datestr(now, 'yyyymmdd_HHMMSS')

    pktTxtFile = strcat(BDATA_DIR, '/', confStr, '.txpkt.txt');
    pktBinFile = strcat(BDATA_DIR, '/', confStr, '.txpkt.dat');
    %iBitsFile  = strcat(BDATA_DIR, '/', confStr, '.ibits.mat');
    %qBitsFile  = strcat(BDATA_DIR, '/', confStr, '.qbits.mat');
    %symbsFile  = strcat(BDATA_DIR, '/', confStr, '.symbs.mat');

    t_pktTxtFile = strcat(BDATA_DIR, '/', confStr, '.txpkt.',dt,'.txt');
    t_pktBinFile = strcat(BDATA_DIR, '/', confStr, '.txpkt.',dt,'.dat');
    %t_iBitsFile  = strcat(BDATA_DIR, '/', confStr, '.ibits.',dt,'.mat');
    %t_qBitsFile  = strcat(BDATA_DIR, '/', confStr, '.qbits.',dt,'.mat');
    %t_symbsFile  = strcat(BDATA_DIR, '/', confStr, '.symbs.',dt,'.mat');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Write pkt to a text file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Write data bits to files
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Write pkt to a binary file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %writeSamplesToTextFile('stf.txt', short_sync_time_total)
    %writeSamplesToBinaryFile('stf160.dat', short_sync_time_total_16bit, 160);
    %writeSamplesToBinaryFile('stf_padded.dat', short_sync_time_total_16bit);

    fprintf(1, 'Writing to %s\n', t_pktTxtFile);
    fprintf(1, 'Writing to %s\n', t_pktBinFile);

    util_writeSamplesToTextFile(t_pktTxtFile, td_pkt_samples_16bit)
    util_writeSamplesToBinaryFile(t_pktBinFile, td_pkt_samples_16bit);
    %save(t_iBitsFile, 'databits_i');
    %save(t_qBitsFile, 'databits_q');
    %save(t_symbsFile, 'datasyms');

    fprintf(1, 'Writing to %s\n', pktTxtFile);
    fprintf(1, 'Writing to %s\n', pktBinFile);

    util_writeSamplesToTextFile(pktTxtFile, td_pkt_samples_16bit)
    util_writeSamplesToBinaryFile(pktBinFile, td_pkt_samples_16bit);
    %save(iBitsFile, 'databits_i');
    %save(qBitsFile, 'databits_q');
    %save(symbsFile, 'datasyms');


    % C-style trace file
    INP_FILE = strcat(confStr, '.txpkt.dat');
    ns_to_skip = 0;
    ns_to_write = length(td_pkt_samples_16bit);
    ns_per_iter = length(td_pkt_samples_16bit);
    util_binToTxt(BDATA_DIR, INP_FILE, ns_to_skip, ns_to_write, ns_per_iter);
end
