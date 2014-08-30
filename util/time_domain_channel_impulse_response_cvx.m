function hhat_feasible = time_domain_channel_impulse_response_cvx( xl, yl, taplength, technique, technique_params)
%form the toeplitz matrix for convolution with the original signal; throw out
%taplength part from the beginning to ensure we do not suffer from ISI in our
%channel impulse response estimation
x=xl(taplength:end)
y=yl(taplength:end)
lenx = length(x)
leny = length(y)
if lenx < taplength
    display('WARNING: too few samples for solving for channel impulse response')
end

X=convmtx(xl(:),taplength);
Xr=X(taplength:end-taplength+1,:);

y=y(:);

hhat_feasible = {};
if (strcmp(technique, 'joint optimization'))
    for p_l = -20:1:20
        cvx_begin
        variable hhat_cvx(taplength) complex
        minimize (norm(Xr*hhat_cvx - y, 2) + 10^p_l*sum(abs(hhat_cvx)));
        subject to
        cvx_end
        if (strcmp(cvx_status, 'Solved'))
            paths_found = length(find(hhat_cvx > technique_params.thresh_factor*max(hhat_cvx)));
            if (paths_found == technique_params.num_paths)
                hhat_feasible{end+1} = hhat_cvx;
                figure
                stem(abs(hhat_cvx))
                title(['weighting factor = 10^',num2str(p_l)])
            end
        end
    end
elseif (strcmp(technique, 'l1 minimization'))
    cvx_begin
    variable hhat_cvx(taplength) complex
    minimize sum(abs(hhat_cvx));
    subject to
    norm(Xr*hhat_cvx - y, 2) <= technique_params.error_norm_bound;
    cvx_end
    hhat_feasible = hhat_cvx;
    figure 
    stem(abs(hhat_feasible))
end

end

