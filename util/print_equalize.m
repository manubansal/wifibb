
%----------------------------------------------------------------------------------------------------------------------------
function print_equalize(rx_data_syms)
%----------------------------------------------------------------------------------------------------------------------------
  fprintf(1,'\nbegin print_equalize');

  fprintf(1,'\nequalized constellation points of symbols\n');
  size(rx_data_syms)
  
  nsyms = size(rx_data_syms, 2)

  factor = 60/0.93;
  rx_data_syms = fix(rx_data_syms * factor);

  for i = 1:nsyms
	  i = i
          symi_eq_pnts = [(1:48)' rx_data_syms(:, i)]
          pause
  end
  pause


  fprintf(1,'end print_equalize\n');
end
