
function bin_msg_tx_w_crc = wifi_append_crc32(bin_msg_tx)
  crc_val_tx = wifi_bit_crc32_v2(bin_msg_tx);
  bin_msg_tx_w_crc = [bin_msg_tx; crc_val_tx];
end
