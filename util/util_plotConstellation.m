
%------------------------------------------------------------------------------------
function util_plotConstellation(rx_data_syms, figure_handle, subplot_handles)
%------------------------------------------------------------------------------------
    rx_const_pnts = reshape(rx_data_syms, prod(size(rx_data_syms)), 1);

    if nargin < 3
      display('creating constellation figure handle')
      figure_handle = figure()
      subplot_handles = {}
      for ii = 1:4
	subplot_handles{ii} = subplot(2,2,ii)
      end
    end

    figure(figure_handle);


    %subplot(2,2,1)
    subplot(subplot_handles{1})
    %axis([-3 3 -3 3]); 
    plot(real(rx_const_pnts), imag(rx_const_pnts), 'b.')
    xlim([-3 3]);
    ylim([-3 3]); 
    grid on
    title('rx constellation map');
    axis equal;

    rx_data_syms_inner = rx_data_syms([13:36],:);
    rx_const_pnts_inner = reshape(rx_data_syms_inner, prod(size(rx_data_syms_inner)), 1);

    %subplot(2,2,2)
    subplot(subplot_handles{2})
    %axis([-3 3 -3 3]); 
    plot(real(rx_const_pnts_inner), imag(rx_const_pnts_inner), 'b.')
    xlim([-3 3]);
    ylim([-3 3]); 
    grid on
    title('rx constellation map, inner subcarriers');
    axis equal;

    rx_data_syms_outer = rx_data_syms([1:12 37:48],:);
    rx_const_pnts_outer = reshape(rx_data_syms_outer, prod(size(rx_data_syms_outer)), 1);

    %subplot(2,2,3)
    subplot(subplot_handles{3})
    %axis([-3 3 -3 3]); 
    plot(real(rx_const_pnts_outer), imag(rx_const_pnts_outer), 'b.')
    xlim([-3 3]);
    ylim([-3 3]); 
    grid on
    title('rx constellation map, outer subcarriers');
    axis equal;

    rx_data_syms_subc_1 = rx_data_syms([25],:);
    rx_const_pnts_subc_1 = reshape(rx_data_syms_subc_1, prod(size(rx_data_syms_subc_1)), 1);

    %subplot(2,2,4)
    subplot(subplot_handles{4})
    %axis([-3 3 -3 3]); 
    plot(real(rx_const_pnts_subc_1), imag(rx_const_pnts_subc_1), 'b.')
    xlim([-3 3]);
    ylim([-3 3]); 
    grid on
    title('rx constellation map, subc_1');
    axis equal;
end
