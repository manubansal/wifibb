
function [corrvec abscorrvec abscorrvecsq norm1val norm2val normval norm1terms norm2terms] = wifi_streamCorrelation(samples, corrwin)
  %size(samples)
  delsamples = samples(1+corrwin:end);				%samples later in time
  delsamples = [delsamples zeros(1,corrwin)];

  %%corrterms = samples .* conj(delsamples);
  corrterms = conj(samples) .* delsamples;			%this order (i.e., which one is conjugated) is 
  								%important for phase offset and, hence, cfo estimation
								%and correction logic, though for timing acquisition, 
								%only the magnitude is important.
  norm1terms = samples .* conj(samples);
  %norm1terms(1:10)'
  %pause
  norm2terms = delsamples .* conj(delsamples);
  %size(corrterms)
%  corrvec_o = [];


  %tic
%  for i = 1:(length(samples)-corrwin)
%    norm1val = sqrt(sum(norm1terms(i:i+corrwin-1)));
%    norm2val = sqrt(sum(norm2terms(i:i+corrwin-1)));
%    normval = norm1val * norm2val;				%TODO : document this in personal notes - using this 
%    								%modified norm term instead of simply norm1val^2.
%    %corrval = sum(corrterms(i:i+corrwin-1));
%    corrval = sum(corrterms(i:i+corrwin-1))/normval;
%    corrvec_o = [corrvec_o corrval];
%  end
  %toc

  %tic
  %c(length(a):end-length(a)+1)
  a = ones(1,corrwin); 
  
  b = norm1terms; c = conv(a,b); 
  norm1val = sqrt(c(corrwin:end-corrwin+1));
  b = norm2terms; c = conv(a,b); 
  norm2val = sqrt(c(corrwin:end-corrwin+1));

  normval = norm1val .* norm2val;

  b = corrterms; c = conv(a,b); 
  corrvec = (c(corrwin:end-corrwin+1))./normval;
  corrvec(end) = [];

  corrvec = [corrvec zeros(1,corrwin)];
  abscorrvec = abs(corrvec);
  abscorrvecsq = abscorrvec .* abscorrvec;
end
