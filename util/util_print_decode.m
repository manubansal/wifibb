
%----------------------------------------------------------------------------------------------------------------------------
function all_chunks = util_print_decode(rx_data_bits_dec, nbits_per_symbol, nchunks_per_symbol)
%----------------------------------------------------------------------------------------------------------------------------
  all_chunks = [];

  display('decoded bits, each ROW is a symbol (not each column)');
  fprintf(1, 'size of rx_data_bits_dec: %d\n', size(rx_data_bits_dec));
  %pause
  nsyms = ceil(length(rx_data_bits_dec)/nbits_per_symbol);
  fprintf(1, 'nsyms: %d\n', nsyms);
  nbits_ceil = nsyms * (nbits_per_symbol);
  fprintf(1, 'nbits_ceil: %d\n', nbits_ceil);
  padlength = nbits_ceil - length(rx_data_bits_dec);
  fprintf(1, 'padlength: %d\n', padlength);
  rx_data_bits_dec =  [rx_data_bits_dec; zeros(padlength, 1)];
  %dec_bits_reshape = reshape(rx_data_bits_dec, nbits_per_symbol, nsyms)';
  %dec_bits_out = [(1:nsyms)' dec_bits_reshape]
  nchunks = nsyms * nchunks_per_symbol;
  nbits_per_chunk = nbits_per_symbol/nchunks_per_symbol;
  dec_bits_reshape = reshape(rx_data_bits_dec, nbits_per_chunk, nchunks)';
  %dec_bits_out = dec_bits_reshape
  b = 2.^[7:-1:0];
  %dec2bin(sum(a.*b), 5)
  nbits_pad_chunk = 32 * ceil(nbits_per_chunk/32) - nbits_per_chunk;
  fprintf(1, 'nbits_pad_chunk: %d\n', nbits_pad_chunk);
  pad_chunk = zeros(1, nbits_pad_chunk);
  noctets = (nbits_per_chunk + nbits_pad_chunk)/8;
  nwords = noctets/4;
  fprintf(1, 'noctets: %d, nwords: %d\n', noctets, nwords);
  for i = 1:nchunks
    fprintf(1, 'chunk_number=%d\n', i)
    chunk = [dec_bits_reshape(i,:) pad_chunk];
    all_chunks = [all_chunks chunk];
    for j = 1:nwords
      si = 1 + (j-1)*32;
      word = chunk(si : si + 32 - 1);
      for k = 1:4
        octet = word(1+(k-1)*8 : k*8);
	os = dec2bin(sum(octet .* b), 8);
	fprintf(1, '%s ', os)
      end
      fprintf(1, '\n')
    end
  end

  all_chunks = all_chunks(:);
end
