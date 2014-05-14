function [crc_val crcValid] = wifi_crc32(msg)
  rx_crc_hex = msg(end-3:end,:);
  msg_no_crc = msg(1:end-4,:);

  [msg_bin_lin msg_len] = util_hexToBinLin(msg_no_crc);
  [rx_crc_bin_lin] = util_hexToBinLin(rx_crc_hex);

  computed_crc = wifi_bit_crc32(msg_bin_lin);

  crc_val = computed_crc;
  crcValid = sum(computed_crc == rx_crc_bin_lin) == 32;
end

