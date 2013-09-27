function test_wifi_softDepuncture()
  test_threefourths();
end

function test_threefourths()
  n_bits = 6 * 4;
  cbits = randint(n_bits, 1);
  pbits = wifi_puncturer_threefourths(cbits)
  size(pbits)
  pbits = str2num(pbits)
  pause
  display('depuncturing:');
  nbits = 6;
  scale = 2^nbits - 1;
  spbits = pbits * scale
  coderateTimes120 = 90;
  dpbits = wifi_softDepuncture(spbits, nbits, coderateTimes120);
  [cbits dpbits]
end
