function opt = util_rx_fig_init(opt)

  if (opt.GENERATE_ONE_TIME_PLOTS_PRE)
    display('creating handle for one-time figure')
    opt.fig_handle_onetime = figure();
    opt.subplot_handles_streamcorr = {};
    opt.subplot_handles_streamcorr{1} = subplot(4,2,[1 2]);
    opt.subplot_handles_streamcorr{2} = subplot(4,2,[3 4]);
    opt.subplot_handles_streamcorr{3} = subplot(4,2,5);
    opt.subplot_handles_streamcorr{4} = subplot(4,2,7);
    opt.subplot_handles_streamcorr{5} = subplot(4,2,[6 8]);
  end

  if (opt.GENERATE_PER_PACKET_PLOTS || ...
  	opt.GENERATE_PER_PACKET_PLOTS_CHANNEL || ...
	opt.GENERATE_PER_PACKET_PLOTS_CONSTELLATION)
    display('creating handle for per-packet figure')
    nsr = 7;
    nsc = 3;
    opt.figure_handle_perpkt = figure();
    opt.perpkt_subplot_handles = {}
    for ii = 1:(nsc*nsr)
      opt.perpkt_subplot_handles{ii} = subplot(nsr,nsc,ii);
    end
    opt.subplot_handles_channel = {}
    opt.subplot_handles_channel{1} = opt.perpkt_subplot_handles{1}
    opt.subplot_handles_channel{2} = opt.perpkt_subplot_handles{4}
    opt.subplot_handles_channel{3} = opt.perpkt_subplot_handles{7}
    opt.subplot_handles_channel{4} = opt.perpkt_subplot_handles{10}
    opt.subplot_handles_channel{5} = opt.perpkt_subplot_handles{13}
    opt.subplot_handles_channel{6} = opt.perpkt_subplot_handles{16}
    opt.subplot_handles_channel{7} = opt.perpkt_subplot_handles{19}
    opt.subplot_handles_constellation = {}
    opt.subplot_handles_constellation{1} = subplot(nsr,nsc,[2 5])
    opt.subplot_handles_constellation{2} = subplot(nsr,nsc,[3 6])
    opt.subplot_handles_constellation{3} = subplot(nsr,nsc,[8 11])
    opt.subplot_handles_constellation{4} = subplot(nsr,nsc,[9 12])
    opt.subplot_handles_constellation2 = {}
    opt.subplot_handles_constellation2{1} = subplot(nsr,nsc,[14 15])
    opt.subplot_handles_constellation2{2} = subplot(nsr,nsc,[17 18])
    opt.subplot_handles_constellation2{3} = subplot(nsr,nsc,[20 21])
    display('created figure and subplot handles')
  end
end
