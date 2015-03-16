function [DATA_DIR, TRACE_DIR, CDATA_DIR, BDATA_DIR] = setup_paths()
  cwd = pwd();
  addpath([cwd '/wifi']);
  addpath([cwd '/util']);
  addpath([cwd '/unittests']);
  addpath([cwd '/mimoch']);
  addpath([cwd '/loc']);
  addpath([cwd '/toplevel']);
  addpath([cwd '/examples']);
  addpath([cwd '/parambuilders']);
  addpath([cwd]);

  setenv('TRACE_DIR', [cwd '/traces']);
  setenv('DATA_DIR', strcat(getenv('TRACE_DIR'), '/data'));

  TRACE_DIR = [cwd '/traces'];
  DATA_DIR = strcat(TRACE_DIR, '/data');
  CDATA_DIR = strcat(TRACE_DIR, '/cdata');	%c-style data
  BDATA_DIR = strcat(TRACE_DIR, '/bdata');	%binary data
end
