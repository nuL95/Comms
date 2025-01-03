% Author: Mark Blair
% 12/30/2024
% This code just does equalization

clear;
close all;
%% Signal and system parameters
N = 1000;
chan = [0 1];
trainingLength = 100;
dat = randi([0 3], N,1);
syms = real(pammod(dat, 4));
sps = 8;
span = 10;
beta = 0.6;
nyq_filter = rcosdesign(beta, span, sps, 'sqrt');
eq_len = 31;
mu = 0.01;
%% Signal Generation
tx = upfirdn(syms,nyq_filter,sps);
rx = filter(chan,1,tx);
ref_sig = rx(1:sps*trainingLength+(span-1)*sps+1);
%% LMS Equalizer algorithm
w = zeros(eq_len,1);
err = zeros(length(ref_sig),1);
eq_out = zeros(length(ref_sig),1);
for k = eq_len:length(ref_sig)
    rr = rx(k:-1:k-eq_len+1);
    eq_out(k-eq_len+1) = w'*rr;
    err(k-eq_len+1) = ref_sig(k)-eq_out(k-eq_len+1);
    w = w + mu*rr*err(k-eq_len+1);
end
%% Recovery using trained equalizer
rx_rec = filter(w,1,rx);
rx_rec = filter(nyq_filter,1,rx_rec);
syms_rec = rx_rec(1:sps:end);
syms_rec = syms_rec(span+1:N+span);
for ii = 1:length(syms_rec)
    syms_rec(ii) = quantalph(syms_rec(ii),[-3 -1 1 3]);
end
%% Error analysis
numErrors = 0;
for ii = 1:length(syms_rec)
    if syms_rec(ii) ~= syms(ii)
        numErrors = numErrors+1;
    end
end
numErrors
%%
figure(1)
plot(filter(nyq_filter,1,tx))
title('Original signal (without channel distortion) and equalizer output')
hold on
plot(rx_rec)

function y = quantalph(x, v)
    dist = zeros(1,length(v));
    for ii = 1:length(v)
        dist(ii) = abs(x-v(ii));
    end
    [val, ind] = min(dist);
    y = v(ind);
end