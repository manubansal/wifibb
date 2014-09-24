function [h, ltf_x] = wifi_time_domain_channel_impulse_response(ltf_sync_freq_domain, ltf_samples, cplen)
  ltf_sync_freq_domain = ltf_sync_freq_domain.';
  %ltf_x = ifft(ltf_sync_freq_domain);
  ltf_x = ifft(ifftshift(ltf_sync_freq_domain));
  ltf_x = [ltf_x(end-2*cplen+1:end) ltf_x ltf_x];
  ltf_y = ltf_samples;

  %taplength = 80;
  taplength = 70;
  %taplength = 64;
  %taplength = 63;
  %taplength = 52;
  %taplength = 58;
  %taplength = 58;
  %taplength = 40;

  ltf_x = ltf_x(4:end-4);   %throw away some samples from beginning and end to remove windowing distortion effects
  ltf_y = ltf_y(4:end-4);
  h = time_domain_channel_impulse_response(ltf_x, ltf_y, taplength);

%   technique = 'joint optimization';
%   technique_params.num_paths = 2;
%   technique_params.thresh_factor = 0.1;
%   technique = 'l1 minimization';
%   technique_params.error_norm_bound = 50;
%   h = time_domain_channel_impulse_response_cvx(ltf_x, ltf_y, taplength, technique, technique_params);

  stem(abs(h))
  xlabel('Sample index','FontSize',20)
  ylabel('Relative magnitude','FontSize',20)
end
