%implementing because R2010b doesn't have it
function ret = de2bi(arg1, arg2, arg3)
  if nargin >= 3
    if strcmp(arg3, 'left-msb')
	a = dec2bin(arg1, arg2);
    else
      error(['ERROR: bad argument: ',arg3])
    end
  else
    a = fliplr(dec2bin(arg1, arg2));
  end

  for i = 1:length(a)
    b(i) = str2num(a(i));
  end
  ret = b;
end
