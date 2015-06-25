function noisy_samples = wifi_awgn(clean_samples, snr, sigpower_dBW,seed)
  if nargin < 4
    randstreamseed = 5489;		%a fixed value for reproducible results
  else
    randstreamseed = seed;
  end
  %randstreamseed = 'shuffle';
  if snr < Inf
    if strcmp(version('-release'),'2010b')
      randn('seed',randstreamseed);
      if nargin < 3
      noisy_samples = awgn(clean_samples, snr, 'measured');
      else
      noisy_samples = awgn(clean_samples, snr, sigpower_dBW);
      end
    else		%assuming higher than 2010b
      randstream = RandStream('mt19937ar','seed',randstreamseed);
      if nargin < 3
      noisy_samples = awgn(clean_samples, snr, 'measured',randstream);
      else
      noisy_samples = awgn(clean_samples, snr, sigpower_dBW,randstream);
      end
    end
  else
    noisy_samples = clean_samples;
  end
end
