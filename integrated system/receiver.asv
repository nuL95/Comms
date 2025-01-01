%Author: Mark Blair
%12/30/2024
%This is the receiver that will attempt to recover the message sent my
%transmitter.m, taking into account the carrier and timing recovery as well
%as equalization
clear;
close all;

tx_dat = load("tx_dat.mat");
%% System Parameters
fs = tx_dat.fs;
fc = tx_dat.fc;
tx = tx_dat.tx;
tr_seq = tx_dat.training_sequence;
N = tx_dat.N;
syms = tx_dat.syms;
nyq_fil = tx_dat.nyq_fil_original;
t = 0:1/fs:(1/fs)*length(tx)-(1/fs);
%% AGC Module Will work on later
step_AGC = 0.1;
AGC_len = 3e3;
a = zeros(AGC_len,1); a(1) = 1;
s = zeros(AGC_len,1);
target_pow = 1;
lenavg = 10;
avec = zeros(1,lenavg);
for k = 1:AGC_len-1
    s(k) = a(k)*tx(k);
    avec = [(s(k)^2-target_pow)*(s(k)^2)/a(k), avec(1:end-1)];
    a(k+1) = a(k) - step_AGC*mean(avec);
end
a(end) = 1;
rx_agc_out = tx*a(end);
%% Carrier recovery
r_pll = tx.^2;
%The frequencies for the bandpass filter depends on fc, and the desired
%number of taps, for the loop filter, it depends on the signal bandwidth,
%which is around 30khz, and desired filter length.
[no,fo,mo,wo] = firpmord([150000 159000 161000 170000],[0 1 0], [.1 0.01 .1],fs);
bpf_taps = firpm(no,fo,mo,wo);
[no,fo,mo,wo] = firpmord([35e3 50e3],[1 0], [.01 .1],fs);
loop_filter = firpm(no,fo,mo,wo);
r_pll = filter(bpf_taps,1,r_pll);

step_phase = 0.01;
step_freq = 0.1;
theta = zeros(1,length(t));
omega = zeros(1,length(t));
f1 = zeros(length(loop_filter),1);
f2 = zeros(length(loop_filter),1);
for k = 1:length(t)
z1 = r_pll(k)*sin(4*pi*fc*t(k)+2*omega(k));
z2 = r_pll(k)*sin(4*pi*fc*t(k)+2*omega(k)+2*theta(k));
f1 = [f1(2:end); z1];
f2 = [f2(2:end); z2];
omega(k+1) = omega(k) - step_freq*fliplr(loop_filter)*f1;
theta(k+1) = theta(k) - step_phase*fliplr(loop_filter)*f2;
carrier_sync(k) = cos(2*pi*fc*t(k)+theta(k)+omega(k));
end
% figure(2)
% subplot(2,1,1)
% plot(omega)
% title('omega')
% subplot(2,1,2)
% plot(theta)
% title('theta')

rx = tx_dat.tx.*carrier_sync;

%% Timing Recovery
step_timing = 1;
timing_length = 1000;
tau = zeros(1,timing_length); tau(1) = 4;
symTime = length(nyq_fil)-1;
delta = 1;
rx_ps_rec = filter(nyq_fil,1,rx); %somehow ive lost the last symbol...
for k = 1:length(tau)
    xc = interpsinc(rx_ps_rec,symTime+tau(k));
    xp = interpsinc(rx_ps_rec,symTime+tau(k)+delta);
    xn = interpsinc(rx_ps_rec,symTime+tau(k)-delta);
    dx = xp-xn;
    tau(k+1) = tau(k) + step_timing*xc*dx;
    symTime = symTime + tx_dat.sps;
end
tau_est = round(mean(tau(end-100:end)));
y = rec_sym(rx_ps_rec,tx_dat.sps,tau_est,length(nyq_fil));
for ii = 1:length(y)
yq(ii) = quantalph(y(ii), [-1 1]);
end
%% Equalizer
step_eq = 0.01;
eq_len = 31;
ref_sig = tx_dat.tx_syms(1:tx_dat.sps*length(tr_seq)+(tx_dat.span-1)*tx_dat.sps+1);
w = zeros(eq_len,1);
err = zeros(length(ref_sig),1);
eq_out = zeros(length(ref_sig),1);
for k = eq_len:length(ref_sig)
    rr = rx(k:-1:k-eq_len+1)';
    eq_out(k-eq_len+1) = w'*rr;
    err(k-eq_len+1) = ref_sig(k)-eq_out(k-eq_len+1);
    w = w + step_eq*rr*err(k-eq_len+1);
end
rx_rec = filter(w,1,rx);
rx_rec = filter(nyq_fil,1,rx_rec);
% test to see how well we have recovered from the channel
% test = filter(nyq_fil,1,tx_dat.tx_syms);
% figure(1)
% plot(rx_rec(1:10e3))
% hold on
% plot(test(1:10e3))

syms_rec = rx_rec(1+tau_est:tx_dat.sps:end);
syms_rec = syms_rec(tx_dat.span+1:length(tr_seq)+N+tx_dat.span-tx_dat.sps);
for ii = 1:length(syms_rec)
    syms_rec(ii) = quantalph(syms_rec(ii),[-1 1]);
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
function y = rec_sym(x,sps,tau,len)
    y = x(len+tau:sps:end);
end
function  y = interpsinc(x,val)
    t = 0:length(x);
    if length(t) ~= length(x)
        t(end) = [];
    end
    snc = sinc(t-val);
    y = snc*x';
end
function y = quantalph(x, v)
    dist = zeros(1,length(v));
    for ii = 1:length(v)
        dist(ii) = abs(x-v(ii));
    end
    [val, ind] = min(dist);
    y = v(ind);
end