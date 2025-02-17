% Author: Mark Blair
% 12/30/2024
% Most of this code is for verication purposes, it does work which means
%once it has been used on the training signal, w can be employed to
%equalize the actual data sequence.

clear;
close all;
N = 100;
dat = randi([0 3], N,1);
syms = real(pammod(dat, 4));
sps = 8;
span = 10;
beta = 0.6;
nyq_filter = rcosdesign(beta, span, sps, 'sqrt');
eq_len = 21;
mu = 0.01;
ref_sig = upfirdn(syms,nyq_filter,sps);
rx_ref = filter(nyq_filter,1,ref_sig);

ref_sym = rx_ref(1:sps:end);
ref_sym = ref_sym(span+1:end);

chan = [0.05 1 -0.6 .02 .1 .02 -.1];
rx = filter(chan,1,ref_sig);
mu = 0.1;
w = zeros(eq_len,1);
err = zeros(length(ref_sig),1);
eq_out = zeros(length(ref_sig),1);
for k = eq_len:length(ref_sig)
    rr = rx(k:-1:k-eq_len+1);
    eq_out(k-eq_len+1) = w'*rr;
    err(k-eq_len+1) = ref_sig(k)-eq_out(k-eq_len+1);
    w = w + mu*rr*err(k-eq_len+1);
end


sig_rec = [zeros(eq_len-1,1)' eq_out'];
syms_rec = filter(nyq_filter,1,sig_rec);
syms_rec = syms_rec(1:sps:end);
syms_rec = syms_rec(span+1:N+span);
for ii = 1:length(syms_rec)
    syms_rec(ii) = quantalph(syms_rec(ii),[-3 -1 1 3]);
end
numErrors = 0;
for ii = 1:length(syms_rec)
    if syms_rec(ii) ~= syms(ii)
        numErrors = numErrors+1;
    end
end
numErrors

figure(1)
plot(err)
title('error')
figure(2)
plot(ref_sig)
title('reference signal and equalizer output')
hold on
plot(eq_out)

function y = quantalph(x, v)
    dist = zeros(1,length(v));
    for ii = 1:length(v)
        dist(ii) = abs(x-v(ii));
    end
    [val, ind] = min(dist);
    y = v(ind);
end