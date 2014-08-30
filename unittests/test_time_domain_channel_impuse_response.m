function chir
  taplength=64;
  %taplength=16;
  cplen=16;

  h=zeros(1,taplength);
  h(1:5)=[1 2 3 4 5];

  x=rand(1,64);
  xl=[x(end-cplen*2+1:end) x x];
  pre=rand(1,100);
  xll=[pre xl];

  yll=conv(xll,h);
  yl=yll(101:end-taplength+1);
  %lenxll = length(xll)
  %lenyll = length(yll)
  %lenxl = length(xl)
  %lenyl = length(yl)
  %pause

  hhat = time_domain_channel_impulse_response(xl,yl,taplength)
  stem(abs(hhat))
end
