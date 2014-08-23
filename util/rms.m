function r = rms(v)
  v = v(:);
  r = sqrt((v.' * v)/length(v));
end 
