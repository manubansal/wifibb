% Convert a binary sample trace file to a txt representation 
% containing a C-language array representation of the txt data,
% suitable for using with a C wifi decoder chain.

%----------------------------------------------------------------------------------------------------------------------------
function util_binToTxt()
%----------------------------------------------------------------------------------------------------------------------------
  DATA_DIR = '../wifibb-traces/data1'
  INP_FILE = 'trace.dat'

  %ns_to_skip  = 0;
  %ns_to_write = 800000;

  %ns_to_skip  = 400000;
  %ns_to_write = 100000;
  %ns_per_iter = 10000;

  ns_to_skip  = 400000;
  %ns_to_write = 10000;
  ns_to_write = 50000;
  ns_per_iter = 10000;

  %ns_to_skip  = 0;
  %ns_to_write = 8000;
  %ns_per_iter = 8000;

  %inpfilename = '../traces/trac-wifi-sbx-decim/trace.dat'
  %inpfilename = 'cdata/trace_6mbps.dat'
  %inpfilename = 'traces-wifi-sbx-decim/rxpkts_nsyms_100Budp_rev_mod_6M_scale_wifi_atten_20.20.30_rxgain_0.dat'
  %tracename = strcat('trace_6mbps_skip_',num2str(ns_to_skip),'_ns_',num2str(ns_to_write));
  %outfilename = strcat('cdata/',tracename,'.c');
  inpfilename = strcat(DATA_DIR,'/',INP_FILE)
  tracename = strcat('trace_skip_',num2str(ns_to_skip),'_ns_',num2str(ns_to_write));
  outfilename = strcat(DATA_DIR,'/',tracename,'.c')


  convertFile(filename, outfilename, ns_to_skip, ns_to_write, ns_per_iter, tracename);
end

%----------------------------------------------------------------------------------------------------------------------------
function convertFile(filename, outfilename, ns_to_skip, ns_to_write, ns_per_iter, tracename);
%----------------------------------------------------------------------------------------------------------------------------

  fid=fopen(filename,'r');
  outfd = fopen(outfilename, 'w');

  skip = ns_to_skip;

  st = fseek(fid, 4*skip, 'bof');
  if (st < 0)
    display('Could not seek file to skip samples');
    error('SeekError','SeekError');
  end

  niter = ns_to_write/ns_per_iter;
  ns = ns_per_iter;

  %fprintf(outfd, '#include "swpform.h"\n\nUint16 traceData[] = {\n');
  fprintf(outfd, '#include "swpform.h"\n\nInt16 %s[] = {\n',tracename);

  for (i = 1:niter)
	  display(strcat(num2str(i),'.of.',num2str(niter)));
	  if (ns == 0)
	    [d,count]=fread(fid,[2,inf],'int16');
	  else
	    [d,count]=fread(fid,[2,ns],'int16');
	  end
	  %%%%samples = (d(1,:) + i * d(2,:))/32767;
	  %%%%samples = samples.';
	  %count
	  %length(samples)

	  %h = dec2hex(d,8);

	  %for (j = 1:2:(ns*2))
	  for (j = 1:ns)
		  %fprintf(outfd,'0x%s, 0x%s,\n', h(j,:), h(j+1,:));
		  fprintf(outfd,'%10d, %10d,\n', d(1,j), d(2,j));
	  end

  end

  fclose(fid);
  fprintf(outfd, '};\n');
  fclose(outfd);

end

