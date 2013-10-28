
function gen_wifi_stf()

  [stf_time_domain, stf_time_domain_16bit] = wifi_shortTrainingField()

  fname=strcat(DATA_DIR, '/stf.txt')
  fid=fopen(fname,'w');
  for ii = 1:length(stf_time_domain)
  %    save('preamble_oversampled.txt','-ascii','pciri');
      fprintf(fid,'{%4d, %4d},\n',real(stf_time_domain_16bit(ii)),imag(stf_time_domain_16bit(ii)));
  end
  fclose(fid);

  fname = strcat(DATA_DIR,'/stf160.dat')
  fid=fopen(fname,'w');
  rr=real(stf_time_domain_16bit(1:160));
  ii=imag(stf_time_domain_16bit(1:160));
  ri = [rr ii].';
  display('writing the following as interleaved 16bit signed integers in column order to binary file:')
  ri
  fwrite(fid, ri, 'int16', 'ieee-be');
  fclose(fid);

  %fid=fopen('data/stf_padded.dat','w');
  %rr=real(stf_time_domain_16bit);
  %ii=imag(stf_time_domain_16bit);
  %ri = [rr ii].';
  %display('writing the following as interleaved 16bit signed integers in column order to binary file:')
  %ri
  %fwrite(fid, ri, 'int16');
  %fclose(fid);
end
