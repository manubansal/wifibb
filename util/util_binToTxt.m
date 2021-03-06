% Convert a binary sample trace file to a txt representation 
% containing a C-language array representation of the txt data,
% suitable for using with a C wifi decoder chain.

%----------------------------------------------------------------------------------------------------------------------------
function util_binToTxt(DATA_DIR, INP_FILE, ns_to_skip, ns_to_write, ns_per_iter, suffix)
%----------------------------------------------------------------------------------------------------------------------------
  if (nargin < 2)

  %DATA_DIR = '../wifibb-traces/data1'
  [DATA_DIR, TRACE_DIR] = setup_paths();

  INP_FILE = 'trace.dat'

  end

  if (nargin < 4)
  %ns_to_skip  = 0;
  %ns_to_write = 800000;

  %ns_to_skip  = 400000;
  %ns_to_write = 100000;

  ns_to_skip  = 400000;
  %ns_to_write = 10000;
  ns_to_write = 50000;

  %ns_to_skip  = 0;
  %ns_to_write = 8000;
  end

  if (nargin < 5)
  ns_per_iter = 10000;
  end

  if nargin < 6
  suffix = '';
  end


  %inpfilename = '../traces/trac-wifi-sbx-decim/trace.dat'
  %inpfilename = 'cdata/trace_6mbps.dat'
  %inpfilename = 'traces-wifi-sbx-decim/rxpkts_nsyms_100Budp_rev_mod_6M_scale_wifi_atten_20.20.30_rxgain_0.dat'
  %tracename = strcat('trace_6mbps_skip_',num2str(ns_to_skip),'_ns_',num2str(ns_to_write));
  %outfilename = strcat('cdata/',tracename,'.c');
  inpfilename = strcat(DATA_DIR,'/',INP_FILE)
  tracename = strcat('trace_skip_',num2str(ns_to_skip),'_ns_',num2str(ns_to_write),suffix);
  %outfilename = strcat(DATA_DIR,'/',tracename,'.c')
  outfilename = strcat(DATA_DIR,'/',INP_FILE,'_',tracename,'.c')


  fprintf(1, 'Reading from %s\n', inpfilename);
  fprintf(1, 'Writing to %s\n', outfilename);
  convertFile(inpfilename, outfilename, ns_to_skip, ns_to_write, ns_per_iter, tracename);
end

%----------------------------------------------------------------------------------------------------------------------------
function convertFile(filename, outfilename, ns_to_skip, ns_to_write, ns_per_iter, tracename);
%----------------------------------------------------------------------------------------------------------------------------

  fid=fopen(filename,'r');
  outfd = fopen(outfilename, 'a');

  skip = ns_to_skip;

  st = fseek(fid, 4*skip, 'bof');
  if (st < 0)
    display('Could not seek file to skip samples');
    error('SeekError','SeekError');
  end

  niter = ns_to_write/ns_per_iter;
  ns = ns_per_iter;

  %fprintf(outfd, '#include "swpform.h"\n\nUint16 traceData[] = {\n');
  fprintf(outfd, '#include <osl/inc/swpform.h>\n\n')
  line2 = ['#pragma DATA_SECTION(',tracename,', ".trace");\n\n'];
  line3 = ['#pragma DATA_ALIGN(',tracename,', 8);\n\n'];
  fprintf(outfd, line2);
  fprintf(outfd, line3);
  fprintf(outfd, 'Int16 %s[] = {\n',tracename);

  for (i = 1:niter)
	  display(strcat(num2str(i),'.of.',num2str(niter)));
	  if (ns == 0)
	    [d,count]=fread(fid,[2,inf],'int16', 0, 'ieee-be');
	  else
	    [d,count]=fread(fid,[2,ns],'int16', 0, 'ieee-be');
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

