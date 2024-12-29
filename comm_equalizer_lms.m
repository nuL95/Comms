clear;
close all;
N = 1000;
dat = randi([0 3], N,1);
syms = pammod(dat, 4);
sps = 8;
span = 10;
beta = 0.2;
nyq_filter = rcosdesign(beta, span, sps, 'sqrt');
eq_len = 21;
mu = 0.01;
ref_sig = real(upfirdn(syms,nyq_filter, sps));

chan = [0.05 1 -0.6 .02 .1];
rx = filter(chan,1,ref_sig);
mu = 0.1;
w = zeros(eq_len,1);
err = zeros(length(ref_sig)-2*eq_len,1);
eq_out = zeros(length(ref_sig)-eq_len,1);
for k = eq_len:length(ref_sig)-eq_len
    rr = rx(k:-1:k-eq_len+1);
    eq_out(k-eq_len+1) = w'*rr;
    err(k-eq_len+1) = ref_sig(k)-eq_out(k-eq_len+1);
    w = w + mu*rr*err(k-eq_len+1);
end


figure(1)
plot(err)
title('error')
figure(2)
plot(ref_sig)
title('reference signal and equalizer output')
hold on
plot(eq_out)
figure(3)
plot(filter(nyq_filter,1,eq_out))
title('equalizer output after second SRRC Filter')

