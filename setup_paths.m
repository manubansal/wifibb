function [DATA_DIR, TRACE_DIR, CDATA_DIR] = setup_paths()
  addpath('./wifi')
  addpath('./util')
  addpath('./unit_tests')

  setenv('TRACE_DIR', '../wifibb-traces')
  setenv('DATA_DIR', strcat(getenv('TRACE_DIR'), '/data'))

  TRACE_DIR = '../wifibb-traces'
  DATA_DIR = strcat(TRACE_DIR, '/data')
  CDATA_DIR = strcat(TRACE_DIR, '/cdata')
end
