
function [opt] = wifi_common_parameters(opt, cplen)
  opt.sample_duration_sec=50e-9;	%sample duration

  opt.cp_len_s = cplen(1);
  opt.cp_skip = cplen(2);
  opt.cp_len_s_ltf = cplen(3);
  opt.cp_skip_ltf = cplen(4);

  %%opt.cp_len_s = 16;
  %%opt.cp_skip = 16;
  %%%opt.cp_skip = 8;
  %%%opt.cp_skip = 12;

  %opt.cp_len_s = 32;
  %opt.cp_skip = 32;

  %%opt.cp_len_s = 64;
  %%opt.cp_skip = 64;

  %%opt.cp_len_s_ltf = 16;
  %%opt.cp_skip_ltf = 16;


  %%opt.cp_len_s_ltf = 16;
  %%opt.cp_skip_ltf = 16;

  %opt.cp_len_s_ltf = 32;
  %opt.cp_skip_ltf = 32;

  %%opt.cp_len_s_ltf = 64;
  %%opt.cp_skip_ltf = 64;



  opt.fft_size = 64;

  opt.stf_len = 160;								%no. of samples
  opt.ltf_len = 2 * opt.fft_size + 2 * opt.cp_len_s_ltf;			%no. of samples

  opt.stf_shift_len=80;	%used for cfo estimation
  opt.ltf_shift_len=64;	%used for cfo estimation

  opt.sig_len = opt.fft_size + opt.cp_len_s;			%no. of samples in signal field
  opt.sym_len_s = opt.fft_size + opt.cp_len_s;


end
