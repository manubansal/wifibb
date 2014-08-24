
%all_td_pkt_samples_with_zeropads{ii} = [zero_postpad_samples; all_td_pkt_samples{ii}; zero_postpad_samples];
function ys = wifi_fading_channel(xs)
  %y = using_stdchan(x);
  ys = using_rayleighchan(xs);
  %ys = using_passthrough(xs);
end

function ys = using_passthrough(xs)
  ys = xs;
end

function ys = using_rayleighchan(xs)
  %By convention, the first delay is typically set to zero. The first delay
  %corresponds to the first arriving path.

  %For indoor environments, path delays after the first are typically between 1
  %ns and 100 ns (that is, between 1e-9 s and 1e-7 s).

  %For outdoor environments, path delays after the first are typically between
  %100 ns and 10 µs (that is, between 1e-7 s and 1e-5 s). Very large delays in
  %this range might correspond, for example, to an area surrounded by
  %mountains.

  maxfd = 1;
  %ts = 50e-9;
  sampling_rate = 40e6;
  ts = 1/sampling_rate;

  %h = rayleighchan(ts, maxfd, [0 15e-6 32e-6], [0, -3, -3]); %super high delay spread, 15us, 32us
  %h = rayleighchan(ts, maxfd, [0 1.5e-6 3.2e-6], [0, -3, -3]); %very high delay spread, 1.5us, 3.2us
  %h = rayleighchan(ts, maxfd, [0 1.5e-7 3.2e-7], [0, -3, -3]); %high delay spread, 150ns, 320ns
  %h = rayleighchan(ts, maxfd, [0 1.5e-8 3.2e-8], [0, -3, -3]); %high delay spread, 15ns, 32ns
  %h = rayleighchan(ts, maxfd, [0 1.5e-9 3.2e-9], [0, -3, -3]); %high delay spread, 1.5ns, 3.2ns

  %k = 0;
  %k = 1;
  %k = 5;
  %k = 10;
  k = 100;
  h = rayleighchan(ts, maxfd, [0 1.5e-9*k 3.2e-9*k], [0, -3, -3]); %high delay spread, 1.5 * k ns, 3.2 * k ns

  h.NormalizePathGains = 1;
  h.StoreHistory = 1;

  ys = {};
  for ii = 1:length(xs)
    ys{ii} = filter(h, xs{ii});
  end
end

function y = using_stdchan(x)
  %fd = 200; 
  fd = 1; 
  ts = 50e-9; 
  %trms = 0.1e-6;
  %trms = 0.1e-6;
  %trms = 0.1e-6;
  trms = 0.1e-6;
  %chan = stdchan(ts, fd, 'cost207TUx6');
  chan = stdchan(ts, fd, '802.11g', trms);
  chan.NormalizePathGains = 1;
  chan.StoreHistory = 1;
  %chan.StoreHistory = 0;
  y = filter(chan, x);
  %plot(chan);
end
