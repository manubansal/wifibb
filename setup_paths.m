function [DATA_DIR, TRACE_DIR, CDATA_DIR, BDATA_DIR] = setup_paths()
  addpath('./wifi');
  addpath('./util');
  addpath('./unittests');

  setenv('TRACE_DIR', './traces');
  setenv('DATA_DIR', strcat(getenv('TRACE_DIR'), '/data'));

  TRACE_DIR = './traces';
  DATA_DIR = strcat(TRACE_DIR, '/data');
  CDATA_DIR = strcat(TRACE_DIR, '/cdata');	%c-style data
  BDATA_DIR = strcat(TRACE_DIR, '/bdata');	%binary data
end
