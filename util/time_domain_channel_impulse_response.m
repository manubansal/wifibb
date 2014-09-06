%example input to this function in the context of WiFi:
%xl = full 160 samples of time-domain LTF
%yl = full 160 samples of time-domain received samples that correspond to the LTF
function hhat = time_domain_channel_impulse_response(xl,yl,taplength)
  %form the toeplitz matrix for convolution with the original signal; throw out
  %taplength part from the beginning to ensure we do not suffer from ISI in our
  %channel impulse response estimation
  x=xl(taplength:end)
  y=yl(taplength:end)
  lenx = length(x)
  leny = length(y)
  if lenx < taplength
    error('WARNING: too few samples for solving for channel impulse response')
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

  %VERSION 0: UNSTABLE
  % this works only when Xr*Xr.' or Xr'*Xr is invertible; in the case of LTF,
  % Xr has rank=52, which makes both of those matrices non-invertible, making
  % this algorithm unstable/impossible
  %hhat=pinv(Xr)*y;
  
  %VERSION 1: UNSTABLE
  % this solves the same system of linear equations that the above tries to
  % solve, that is, y = Xr * hhat. However, when Xr is rank deficient, MATLAB's
  % implementation of solving this system looks for a solution that minimizes
  % the number of non-zero entries in hhat, that is, a solution in the space of
  % solutions which minimizes the L0-norm of hhat. So, it does more than just
  % trying pinv(Xr)*y when Xr is rank defficient.
  %hhat=Xr\y;
  
  %VERSION 2: STABLE
  %computing with regularization - this allows putting weight on L2-norm
  %minimization, which helps finding a cleaner channel estimate (more
  %realistic) rather than succumbing to over-fitting errors.
  lambda = 0.001;
  Xi = inv(Xr.'*Xr + lambda*eye(size(Xr,2)))*Xr.';
  hhat=Xi*y;
  stem(abs(hhat));
    
  %save_inversion_matrix(Xi);
end

function save_inversion_matrix(Xi)
  Xinv = fix(1000*Xi);
  Yi = real(Xinv);
  Yq = imag(Xinv);
  Yi = reshape(Yi.', [], 1);
  Yq = reshape(Yq.', [], 1);
  Y = [Yi Yq].';
  Y = reshape(Y, [], 1);
  %size(Y)

  data = Y;

  [DATA_DIR, TRACE_DIR, CDATA_DIR, BDATA_DIR] = setup_paths();
  fn = strcat(BDATA_DIR, '/', 'inversion_matrix.txt');
  fprintf(1, ['Writing to ',fn,'\n']);
  f = fopen(fn, 'w');
  %count = fwrite(f, data, 'double', 'ieee-be');
  fprintf(f, '%d,\n', data);
  fclose(f);

  fprintf(1, ['Written to ',fn,'\n']);

end
