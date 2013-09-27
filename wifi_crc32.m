function [crc_val crcValid] = wifi_crc32(msg)

  %ref_crc = ['9a';'aa';'04';'a7'];
  %msg = ['d4'; '00'; '00'; '00'; '00'; '22'; 'b0'; 'e1'; '25'; '16'];

  rx_crc_hex = msg(end-3:end,:);
  msg_no_crc = msg(1:end-4,:);

  %[msg_bin_lin msg_len] = util_hexToBinLin(msg);
  %ref_crc_bin_lin = util_hexToBinLin(ref_crc)

  [msg_bin_lin msg_len] = util_hexToBinLin(msg_no_crc);
  [rx_crc_bin_lin] = util_hexToBinLin(rx_crc_hex);

  %computed_crc = crc32_(msg_bin_lin);
  %[ref_crc_bin_lin computed_crc ref_crc_bin_lin - computed_crc]

  computed_crc = wifi_bit_crc32(msg_bin_lin);
  %[ref_crc_bin_lin computed_crc ref_crc_bin_lin - computed_crc]

  computed_crc_v2 = wifi_bit_crc32_v2(msg_bin_lin);

  %computed_crc_ti = wifi_bit_crc32_ti(msg_bin_lin);
  [computed_crc computed_crc_v2];% computed_crc_ti]
  pause

  crc_val = computed_crc;
  crcValid = sum(computed_crc == rx_crc_bin_lin) == 32;
end

