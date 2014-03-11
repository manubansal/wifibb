
%------------------------------------------------------------------------------------
function [rx_data_bits_dec] = wifi_wrapper_decode(rx_data_bits_depunct, msglen, opt)
%------------------------------------------------------------------------------------
  soft_slice_nbits = opt.soft_slice_nbits;
  tblen = opt.VITDEC_tblen;
  model = opt.VITDEC_MODEL;

  if strcmp(model, 'TERM')
    rx_data_bits_dec = wifi_vdec(rx_data_bits_depunct, soft_slice_nbits, tblen);
  elseif strcmp(model, 'CONVGT')
    chunk_size = opt.VITDEC_chunksize;
    rx_data_bits_dec = wifi_vdec(rx_data_bits_depunct, soft_slice_nbits, tblen, 'trunc', chunk_size, msglen);
  else
    error('bad VITDEC_MODEL')
  end
end

