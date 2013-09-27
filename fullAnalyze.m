
function fullAnalyze(readFromCache, writeToCache)

  %scalesi={'1'     '2'     '4'     '8'    '16'    '32'    '64'   '128'   '256'};
  %scalesq={'r2'    '2r2'   '4r2'   '8r2'  '16r2'  '32r2'  '64r2' '128r2' '256r2'};

  scales = {'1' 'r2' '2' '2r2' '4' '4r2' '8'}
  %scales = {'1' 'r2'};

  %allStatsFile = 'traces/as_m.mat';
  %opt.traceFolder = 'traces/';

  allStatsFile = 'traces/as_j.mat';
  opt.traceFolder = 'traces-decim/';

  opt.mod = 1;			%tx modulation scheme, bpsk is 1, qpsk is 2
  opt.nsyms = 250;		%tx packet length in ofdm symbols
  %opt.scale = scale;
  %opt.rxgain = 35;
  opt.rxgain = 30;
  opt.atten = '30';

  opt.COARSE_CFO_CORRECTION = true;
  opt.FINE_CFO_CORRECTION = true;
  opt.PILOT_PHASE_TRACKING = true;
  opt.PILOT_SAMPLING_DELAY_CORRECTION = false;		%this is really referring to sampling delay 
							%introduced due to sampling frequency offset
  opt.GENERATE_ONE_TIME_PLOTS = false;
  opt.GENERATE_PER_PACKET_PLOTS = false;
  opt.PAUSE_AFTER_EVERY_PACKET = false;

  %scales{1}
  %pause

  if (nargin == 0) 
    readFromCache = 0;
    writeToCache = 0;
  elseif (nargin == 1)
    writeToCache = 0;
  end

  if (readFromCache)
    as = loadStatsFromFile(allStatsFile);
  else
    as = computeStats(scales, opt, allStatsFile, writeToCache);
  end

  plotStats(as);
end

function plotStats(as)
  %as
  figure

  subplot(2,1,1);
  %plot(as.v_avg_snr_db(end:1), as.v_avg_ber(end:1), '*-');
  semilogy(as.v_avg_snr_db(end:-1:1), as.v_avg_ber(end:-1:1), '*-');
  set(gca,'xdir','rev');
  grid on
  title('avg ber vs avg snr');
  xlabel('snr (dB)');
  ylabel('ber');

  %figure
  subplot(2,1,2);
  hold on
  plot(as.v_avg_snr_db, as.v_min_max_corr_val, 'bo');
  plot(as.v_avg_snr_db, as.v_max_max_corr_val, 'r*');
  set(gca,'xdir','rev');
  grid on
  title('max-max corr val (r*) and min-max corr val (bo) vs avg snr');
  xlabel('snr (dB)');
  ylabel('corr val');
end

function as = loadStatsFromFile(file)
  load(file);
end

function as = computeStats(scales, opt, file, writeToCache)

  as.el = [];		%all stats

  as.v_avg_snr_db = [];
  as.v_avg_ber = [];
  as.v_min_max_corr_val = [];
  as.v_max_max_corr_val = [];

  lastctime = 0;
  for i = 1:length(scales)
    tic;
    scale = scales{i};
    display(strcat('scale: ',scale,', #',num2str(i),' of #',num2str(length(scales)),'. Last scale took #',num2str(lastctime),'s to compute.'));
    opt.scale = scale;
    stats = analyzeBinaryPkt(scale, opt)
    as.el = [as.el stats];
    lastctime = toc;

    %stats.avg_snr_lin = -1;
    %stats.avg_snr_db = -1;
    %stats.avg_ber = -1;
    as.v_avg_snr_db(end+1,:) = stats.avg_snr_db;
    as.v_avg_ber(end+1, :) = stats.avg_ber;
    as.v_min_max_corr_val(end+1, :) = stats.min_max_corr_val;
    as.v_max_max_corr_val(end+1, :) = stats.max_max_corr_val;
  end

  if (writeToCache)
    %save all stats to the cache file
    save(file, 'as');
  end
end

