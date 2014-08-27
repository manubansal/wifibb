%By convention, the first delay is typically set to zero. The first delay
%corresponds to the first arriving path.

%For indoor environments, path delays after the first are typically between 1
%ns and 100 ns (that is, between 1e-9 s and 1e-7 s).

%For outdoor environments, path delays after the first are typically between
%100 ns and 10 µs (that is, between 1e-7 s and 1e-5 s). Very large delays in
%this range might correspond, for example, to an area surrounded by
%mountains.


%all_td_pkt_samples_with_zeropads{ii} = [zero_postpad_samples; all_td_pkt_samples{ii}; zero_postpad_samples];
function ys = wifi_fading_channel(xs, ch)
  if strcmp(ch, 'passthrough')
    ys = using_passthrough(xs);
  elseif strncmp(ch, 'r', 1) || strncmp(ch, 't', 1)
    ys = using_rayleighchan(xs, ch);
  elseif strncmp(ch, 'f', 1)
    ys = using_fixedchan(xs, ch);
  %elseif strcmp(ch, 'stdchan')
  %  y = using_stdchan(x);
  else
  %  error('bad channel selection')
  end
end

function ys = using_passthrough(xs)
  ys = xs;
end

function ys = using_fixedchan(xs, ch)
  maxfd = 1;
  sampling_rate = 20e6;
  ts = 1/sampling_rate;

  if strcmp(ch, 'f0')  %Tu ~= 0ns, Trms ~= 0ns
    k = 0;
    tau_ns = [0 k];
    gains = [0, -12];

  elseif strcmp(ch, 'f10')  %Tu ~= 30ns, Trms ~= 118ns 
    k = 10;
    tau_ns = [0 k];
    gains = [0, -12];

  elseif strcmp(ch, 'f20')  %
    k = 20;
    tau_ns = [0 k];
    gains = [0, -12];

  elseif strcmp(ch, 'f50')  %
    k = 50;
    tau_ns = [0 k];
    gains = [0, -12];

  elseif strcmp(ch, 'f100')  %Tu ~= 300ns, Trms ~= 1180ns 
    k = 100;
    tau_ns = [0 k];
    gains = [0, -12];

  elseif strcmp(ch, 'f200')  %Tu ~= 600ns, Trms ~= 2.4us
    k = 1000;
    tau_ns = [0 k];
    gains = [0, -12];

  else
    error('bad channel selection')
  end

  tau = tau_ns * ts;
  pdp = 10.^(gains./10);
  mean_delay = sum(tau .* pdp)/sum(pdp)
  tau_rms = sqrt(sum((tau - mean_delay).^2 .* pdp)/sum(pdp))

  pdp_normalized = pdp/sum(pdp)
  amplitudes_normalized = sqrt(pdp_normalized)
  cir = zeros(max(tau_ns) + 1,1);
  if length(tau_ns) ~= length(gains)
    error('lengths of tau_ns and gains need to be same')
  end
  next = 1;
  for idx = tau_ns
    cir(idx + 1) = amplitudes_normalized(next);
    next = next + 1;
  end
  h = cir

  ys = {};
  for ii = 1:length(xs)
    ys{ii} = filter(h, 1, xs{ii});
  end
end

function ys = using_rayleighchan(xs, ch)
  maxfd = 1;
  sampling_rate = 20e6;
  ts = 1/sampling_rate;

  if strcmp(ch, 'r0')
    k = 0;
    tau = [0 1.5e-9*k 3.2e-9*k];
    gains = [0, -3, -3];

  elseif strcmp(ch, 'r10')  %Tu ~= 12ns, Trms ~= 13ns
    k = 10;
    tau = [0 1.5e-9*k 3.2e-9*k];
    gains = [0, -3, -3];

  elseif strcmp(ch, 'r100')  %Tu ~= 118ns, Trms ~= 132ns
    k = 100;
    tau = [0 1.5e-9*k 3.2e-9*k];
    gains = [0, -3, -3];

  elseif strcmp(ch, 't0')  %Tu ~= 0ns, Trms ~= 0ns
    k = 0;
    tau = [0 1.0e-9*k];
    gains = [0, -12];

  elseif strcmp(ch, 't1')  %Tu ~= 0.06ns, Trms ~= 0.24ns
    k = 1;
    tau = [0 1.0e-9*k];
    gains = [0, -12];

  elseif strcmp(ch, 't10')  %Tu ~= 0.6ns, Trms ~= 2.4ns
    k = 10;
    tau = [0 1.0e-9*k];
    gains = [0, -12];

  elseif strcmp(ch, 't50')  %Tu ~= 3ns, Trms ~= 12.2ns
    k = 50;
    tau = [0 1.0e-9*k];
    gains = [0, -12];

  elseif strcmp(ch, 't100')  %Tu ~= 6ns, Trms ~= 24.3ns
    k = 100;
    tau = [0 1.0e-9*k];
    gains = [0, -12];

  elseif strcmp(ch, 't1000')  %Tu ~= 64ns, Trms ~= 236ns
    k = 1000;
    tau = [0 1.0e-9*k];
    gains = [0, -12];

  else
    error('bad channel selection')
  end

  h = rayleighchan(ts, maxfd, tau, gains); 

  pdp = 10.^(gains./10);
  mean_delay = sum(tau .* pdp)/sum(pdp)
  tau_rms = sqrt(sum((tau - mean_delay).^2 .* pdp)/sum(pdp))

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
