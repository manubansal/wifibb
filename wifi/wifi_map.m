
function [mapped_sym, databits_i, databits_q] = wifi_map(bits, nbpsc)
  if (nbpsc == 1)
    [mapped_sym, databits_i, databits_q] = wifi_mapper_mapbpsk(bits);
  elseif (nbpsc == 2)
    [mapped_sym, databits_i, databits_q] = wifi_mapper_mapqpsk(bits);
  elseif (nbpsc == 4)
    [mapped_sym, databits_i, databits_q] = wifi_mapper_map16qam(bits);
  elseif (nbpsc == 6)
    [mapped_sym, databits_i, databits_q] = wifi_mapper_map64qam(bits);
  else
    error ('bad modulation type','bad modulation type');
  end
end
