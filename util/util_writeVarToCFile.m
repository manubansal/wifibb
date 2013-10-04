
function util_writeVarToCFile(var, varname, nbitsToRightShift, Qval, datatype, forgetbitshift, autosize)

  %parameters for filename
  ns_to_skip  = 400000;
  ns_to_write = 10000;

  tracename = strcat('trace_skip_',num2str(ns_to_skip),'_ns_',num2str(ns_to_write),'_',varname);
  outfilename = strcat('cdata/',tracename,'.c');

  if (nargin > 5 && forgetbitshift)
	  data = var;
  else
	  nbitsToRightShift = nbitsToRightShift
	  room = 4;
	  data = var;
	  data = fix(data * 2^(Qval + room));
	  data = bitshift(data, -(nbitsToRightShift + room));
	  %var(1:10)' 
	  %data(1:10)'
  end

  if (nargin > 6 && autosize)
	  ns_to_write = length(data);
  end

  fullvarname = tracename;
  writeToFile(outfilename, fullvarname, data, ns_to_write, datatype);

  display('file written');
end

function writeToFile(outfilename, fullvarname, data, ns, datatype)
  outfd = fopen(outfilename, 'w');
  line1 = '#include "swpform.h"\n\n';
  lengthline = ['Uint32 ',fullvarname,'_length = ',num2str(ns),';\n\n'];
  line2 = ['#pragma DATA_SECTION(',fullvarname,', ".ddr2");\n\n'];
  line3 = ['#pragma DATA_ALIGN(',fullvarname,', 8);\n\n'];
  fprintf(outfd, [line1,lengthline,line2,line3,datatype,' ',fullvarname,'[] = {\n']);

  for (j = 1:ns)
	  %fprintf(outfd,'0x%s, 0x%s,\n', h(j,:), h(j+1,:));
	  %fprintf(outfd,'%10d, %10d,\n', d(1,j), d(2,j));
	  fprintf(outfd,'%10d,\n', data(j));
  end

  fprintf(outfd, '};\n');
  fclose(outfd);
end
