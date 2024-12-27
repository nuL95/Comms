%% Timing recovery using steepest descent to maximize the energy of each symbol in a PAM4 system using SRRC pulse shaping
clear;close all;
n = 10000;
%% creation of symbols
sps = 6;
beta = 0.3;
chan = [0 1 .3];
dat = randi([0 3],1, n);
s = pammod(dat,4);
sup = zeros(1,n*sps);
sup(1:sps:n*sps) = s;
beta = 0.8;
span = 8;
psf = rcosdesign(beta, span, sps);
%% parameters and setup for timing recovery
l = floor(length(psf)/2);
hh = conv(psf, chan);
r = conv(hh,sup);
x = conv(r,psf);
u = 0.1;
tau = zeros(1,n/100); %tracking the first 100 symbols to find the optimal delay
time = length(psf)-1;
delta = 0.5;
%% Recovery
for k = 1:length(tau)
    xc = interpsinc(x,time+tau(k));
    xp = interpsinc(x,time+tau(k)+delta);
    xn = interpsinc(x,time+tau(k)-delta);
    dx = xp-xn;
    tau(k+1) = tau(k) + u*xc*dx;
    time = time + sps;
end
tau_est = round(mean(tau(round(end/2):end)));
y = rec_sym(x,sps,tau_est,length(psf));
for ii = 1:length(y)
yq(ii) = quantalph(y(ii), [-3 -1 1 3]);
end
if length(yq) ~= n
    yq(end) = [];
end
error = sum(yq-s)
function y = rec_sym(x,sps,tau,len)
    y = x(len+tau:sps:end-len-tau);
end
function  y = interpsinc(x,val)
    t = 0:length(x);
    if length(t) ~= length(x)
        t(end) = [];
    end
    snc = sinc(t-val);
    y = snc*x';
% linear interpolation also works, not as effective but much faster
%     low = x(1+floor(val));
%     high = x(1+ceil(val));
%     slope = high-low;
%     y= low+slope;
end
function y = quantalph(x, v)
    dist = zeros(1,length(v));
    for ii = 1:length(v)
        dist(ii) = abs(x-v(ii));
    end
    [val, ind] = min(dist);
    y = v(ind);
end