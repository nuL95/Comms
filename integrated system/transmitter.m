%Author: Mark Blair
%12/30/2024
%This is the transmitter of a communication system using QAM4 with an
%random phase, frequency, and timing offset.
clear;
close all;
%% Parameters
fc = 80e3;
fs = 500e3;
N = 9500;
beta = 0.4;
sps = 12;
span = 16;
sigPow = sqrt(2);
SNRdb = 40;
noisePow = sigPow/(10^(SNRdb/10));
nyq_fil = rcosdesign(beta,span,sps,"sqrt");
training_sequence = load("training_sequence.mat");
training_sequence = training_sequence.training_sequence;
phi = randi([0 314],1,1)/100;
f0 = randi([-100 100],1,1)/100;
del = randi([0 sps],1,1);
del_resp = [zeros(1,del-1) 1];
% attn_factor = randi([50 350])/100; AGC Factor, or could do fading, will
% work on later
attn_factor = 1;
nyq_fil_original = nyq_fil;
nyq_fil = filter(del_resp,1,nyq_fil);
%% Signals
bits = [training_sequence' randi([0 1], 1, N)];
syms = real(pammod(bits,2));
tx_syms = upfirdn(syms,nyq_fil,sps);
t = 0:1/fs:(1/fs)*length(tx_syms)-(1/fs);
carrier = cos(2*pi*(fc+f0)*t+phi);
tx = real(tx_syms).*carrier;
tx = tx + sqrt(noisePow)*randn(1,length(tx));

%I don't know what a typical channel response looks like, I just used
%random coefficients.
chan = [0.05 .7 0.1 .02 .1 .09];
tx = filter(chan,1,tx);
tx = tx*attn_factor;
%% Frequency analysis
fbins = 4098;
w = -fs/2:fs/fbins:fs/2-fs/fbins;
TX = fftshift(fft(tx,fbins));
%% Plots
figure(1)
subplot(2,1,1)
plot(t,tx);
title('Tx in time-domain')
subplot(2,1,2)
plot(w,abs(TX))
title('Tx in frequency-domain')

name = "tx_dat.mat";
save(name);