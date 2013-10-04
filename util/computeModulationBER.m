
%----------------------------------------------------------------------------------------------------------------------------
function [stats ber] = computeModulationBER(data, opt, stats)
%----------------------------------------------------------------------------------------------------------------------------
  ber = -1;
  stats.ber(end+1,:) = ber;

  if (~opt.tx_known)
    return;
  end

  rx_data_bits_i = data.rx_data_bits_i;
  rx_data_bits_q = data.rx_data_bits_q;

  tx_data_bits_i = data.tx_data_bits_i;
  tx_data_bits_q = data.tx_data_bits_q;


  bit_errors_i = rx_data_bits_i ~= tx_data_bits_i;

  display('no. of bit erros in i channel:')
  n_bit_errors_i = sum(sum(bit_errors_i))

  stats.n_bits_errors_i(end+1,:) = n_bit_errors_i;

  n_bit_errors = n_bit_errors_i;
  nbits = prod(size(tx_data_bits_i));

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % per subcarrier SNR using normalized symbols
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if (data.mod == 1)
    %tx_data_syms = (2*tx_data_bits_i - 1) + i * (2*tx_data_bits_q - 1);	%works for bpsk and qpsk, maps {1, 0} to {1, -1} 
    										%(also need to normalized with sqrt(2) for qpsk)
    tx_data_syms = (2*tx_data_bits_i - 1);
    uu_rx_data_syms = rx_data_syms .* tx_data_syms;	%uu_rx_data_syms normalizes each symbol to map to expected value 1
    mean_rx_symbol = sum(uu_rx_data_syms, 2)/size(uu_rx_data_syms,2);
    noise_matrix = uu_rx_data_syms - diag(mean_rx_symbol) * ones(size(uu_rx_data_syms));
    noise_power_per_subcarrier = sum(noise_matrix .* conj(noise_matrix), 2)/size(uu_rx_data_syms,2);
    signal_power_per_subcarrier = mean_rx_symbol .* conj(mean_rx_symbol);

    snr_per_subcarrier = signal_power_per_subcarrier./noise_power_per_subcarrier;
    snr_per_subcarrier_db = 10*log10(snr_per_subcarrier);

    display('snr values computed using normalized data symbols:');
    net_snr_linear = sum(signal_power_per_subcarrier)/sum(noise_power_per_subcarrier)
    net_snr_db = 10*log10(net_snr_linear)

    stats.net_snr_linear(end+1,:) = net_snr_linear;
    stats.net_snr_db(end+1,:) = net_snr_db;

    if (opt.GENERATE_PER_PACKET_PLOTS)
      figure
      subplot(2,1,1)
      plot(snr_per_subcarrier,'r.-');
      title('snr per subcarrier, linear');
      grid on

      subplot(2,1,2)
      plot(10*log10(snr_per_subcarrier),'r.-');
      title('snr per subcarrier, dB');
      grid on
      %v = axis;
      %v(3) = 0; v(4) = 30;
      %axis(v);
    end
    %pause
  end

  if (data.mod == 2)
    rx_data_syms_q = imag(rx_data_syms);
    rx_data_bits_q = sign(rx_data_syms_q);
    rx_data_bits_q = fix((rx_data_bits_q + 1)/2);	%contains 1 and 0 only

    bit_errors_q = rx_data_bits_q ~= tx_data_bits_q;

    display('no. of bit erros in q channel:')
    n_bit_errors_q = sum(sum(bit_errors_q))

    stats.n_bits_errors_q(end+1,:) = n_bit_errors_q;

    n_bit_errors = n_bit_errors_i + nbit_erros_q;
    nbits = nbits * 2;
  else
    bit_errors_q = zeros(size(bit_errors_i));
  end

  ndsubc = 48;

  n_bits_per_subcarrier = data.mod;
  bit_errors = bit_errors_i + bit_errors_q;		%contains 0, 1 and 2 as entries; 2 means both bits were in error in that symbol
  bit_errors_vs_ofdm_symbol = sum(bit_errors);

  ber_vs_ofdm_symbol = (bit_errors_vs_ofdm_symbol/(n_bits_per_subcarrier * ndsubc))';	%col vector -- easier to see on console
  ber_vs_subcarrier = (sum(bit_errors, 2)/(n_bits_per_subcarrier * size(bit_errors, 2)));	


  %display('ber vs ofdm symbol:');
  %ber_vs_ofdm_symbol

  display('snr(lin), snr(dB), ber per subcarrier:');
  [snr_per_subcarrier snr_per_subcarrier_db ber_vs_subcarrier]


  stats.ber_vs_ofdm_symbol(end+1,:) = ber_vs_ofdm_symbol';		%add a row
  stats.snr_per_subcarrier(end+1,:) = snr_per_subcarrier';		%add a row
  stats.snr_per_subcarrier_db(end+1,:) = snr_per_subcarrier_db';	%add a row
  stats.ber_vs_subcarrier(end+1,:) = ber_vs_subcarrier';		%add a row

  %val = opt.GENERATE_PER_PACKET_PLOTS;
  %opt.GENERATE_PER_PACKET_PLOTS = true;
  if (opt.GENERATE_PER_PACKET_PLOTS)
    figure
    subplot(2,1,1);
    plot(ber_vs_ofdm_symbol, 'r.-');
    title('BER vs OFDM symbol');

    subplot(2,1,2);
    plot(ber_vs_subcarrier, 'r.-');
    title('BER vs OFDM subcarrier');
  end
  %opt.GENERATE_PER_PACKET_PLOTS = val;

  ber = n_bit_errors/nbits;
  stats.ber(end) = ber;
end
