
function [softbits] = wifi_deinterleave(t, softbits, nbpsc)
  if (nbpsc == 1)
    softbits(t.bpsk(:,2), :) = softbits;
  elseif (nbpsc == 2)
    softbits(t.qpsk(:,2), :) = softbits;
  elseif (nbpsc == 4)
    %size(t.qam16)
    %size(softbits)
    softbits(t.qam16(:,2), :) = softbits;
  elseif (nbpsc == 6)
    %size(t.qam64)
    %size(softbits)
    %pause
    softbits(t.qam64(:,2), :) = softbits;
  else
    error ('Unknown modulation type','I dont know how to deinterleave for this modulation type');
  end

end

