%example input to this function in the context of WiFi:
%xl = full 160 samples of time-domain LTF
%yl = full 160 samples of time-domain received samples that correspond to the LTF
function hhat = time_domain_channel_impulse_response(xl,yl,taplength)
  %form the toeplitz matrix for convolution with the original signal; throw out
  %taplength part from the beginning to ensure we do not suffer from ISI in our
  %channel impulse response estimation
  x=xl(taplength:end);
  y=yl(taplength:end);
  lenx = length(x)
  leny = length(y)
  if lenx < taplength
    display('WARNING: too few samples for solving for channel impulse response')
  end

  X=convmtx(xl(:),taplength);
  Xr=X(taplength:end-taplength+1,:);
  %sizeXr = size(Xr)
  %pause

  %y=y(1:end-taplength+1);
  y=y(:);
  %size(Xr)
  %size(y)
  %pause

  %hhat=pinv(Xr)*y;
  hhat=Xr\y;
end
