%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate data portion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [td_data_samples databits_i databits_q datasyms] = gen_random_data_samples(mod, nsyms, databits_i, databits_q)
  bpskmap = [1, -1];
  bpskbmap_i = [1, 0];
  bpskbmap_q = [0, 0];
  qpskmap = [1+i, 1-i, -1-i, -1+i]/sqrt(2);
  qpskbmap_i = [1, 1, 0, 0];
  qpskbmap_q = [1, 0, 0, 1];
  
  if (mod == 1)
    cmap = bpskmap;
    bmap_i = bpskbmap_i;
    bmap_q = bpskbmap_q;
  elseif (mod == 2)
    cmap = qpskmap;
    bmap_i = qpskbmap_i;
    bmap_q = qpskbmap_q;
  else
    error ('badmod', 'bad modulation index');
  end


  ndatasubc = 48;
  if nargin < 4		%generate random data
    idxs=randint(ndatasubc,nsyms,[1 length(cmap)]);
  else			%user provided data
    size(databits_i)
    size(databits_q)
    bmap_iq = [bmap_i; bmap_q]
    all_idxs = [];
    for ii = 1:nsyms
      databits_iq = [databits_i(:,ii) databits_q(:,ii)]'
      [vals,idxs]=ismember(databits_iq',bmap_iq','rows')
      %idxs = idxs
      all_idxs = [all_idxs idxs];
    end
    idxs = all_idxs
  end

  %I- and Q-channel data bits
  %dbi = databits_i
  %dbq = databits_q

  databits_i = bmap_i(idxs);
  databits_q = bmap_q(idxs);

  %sum(sum(abs(dbi - databits_i)))
  %sum(sum(abs(dbq - databits_q)))
  %pause

  datasyms = cmap(idxs);
  if nsyms == 1
    datasyms = datasyms(:)
  end

  %--------------------------------------------------------------------------------------
  [tdsyms_w_cp, tdsyms] = wifi_ofdm_modulate(datasyms)
  %--------------------------------------------------------------------------------------

  %--------------------------------------------------------------------------------------
  td_data_samples = wifi_time_domain_windowing(tdsyms_w_cp, tdsyms)
  %--------------------------------------------------------------------------------------

end
