function noisy_samples = wifi_awgn(clean_samples, snr)
  randstreamseed = 5489;		%a fixed value for reproducible results
  %randstreamseed = 'shuffle';
  if snr < Inf
    randstream = RandStream('mt19937ar','seed',randstreamseed);
    noisy_samples = awgn(clean_samples, snr, 'measured');
  else
    noisy_samples = clean_samples;
  end
end
