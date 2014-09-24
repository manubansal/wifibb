function signal =realch(x,chfile,begsnapshot,endsnapshot)
%Signal: Ns - by- N - by - M
% Ns: Number of snapshots
% M : Number of antennas
% N : Time stamps, length(x)

N = length(x);
%Implements a real channel
load(chfile,'h')
% Ns = size(h(begsnapshot:endsnapshot,:,:),1);
Ns = endsnapshot-begsnapshot+1;
M = size(h,3);
signal = zeros(Ns,N,M); 
for ni = 1:Ns
  for mi = 1:M
    signal(ni,:,mi) = conv(x,h(ni-1+begsnapshot,:,mi),'same');
  end
end

 
end