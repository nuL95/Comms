% Author: Mark Blair
% 12/16/2024
%% Frequency tracking simulation using a dual loop PLL for a PAM4 system using SRRC pulse shaping
clear;
close all;
%% Pulse shaping filter
beta = 0.8;
span = 13;
sps = 10;
psf = rcosdesign(beta, span, sps);
%% Communication parameters, data stream, pulse shaping
fs = 30e3;
fc = 5e3;
N = 10000;
noisePow = 1e-5;
phi = randi([0 314])/100;
phi = 2; %fixed phase offset for now, there is still a +/- pi ambiguity for phase tracking
w = -fs/2:fs/N:fs/2-fs/N;
syms = randi([0 3], N, 1);
syms = pammod(syms,4);
psym = filter(psf,1,upsample(syms, sps));
t = 0:1/fs:length(psym)/fs-1/fs; 
%% Transmission
cosm = cos(2*pi*fc*t+phi);
noise = sqrt(noisePow)*randn(1,length(psym));
tx = real(psym).*cosm';
rx = tx+noise';
%% Preprocessing and set up for phase and frequency tracking
[n, f0,a0,w0] = firpmord([9000 9500 10500 11000], [0 1 0], [0.1, .01, 0.1], fs);
hbpf = firpm(n,f0,a0,w0);
rp = filter(hbpf,1,rx.^2);
up=0.001;
uf=0.01;
[n, f0,a0,w0] = firpmord([3000, 3500], [ 1 0], [0.01, 0.1], fs);
h = firpm(n,f0,a0,w0);
z1 = zeros(1,length(h));
z2 = zeros(1,length(h));
theta = zeros(1,length(t));theta(1) = 0;
omega = zeros(1,length((t)));omega(1)=0;
f0 = fc + 2;
%% phase and frequency tracking, synthesis of demodulating oscillators
for k = 1:length(t)
filtin1 = rp(k)*sin(4*pi*f0*t(k)+2*omega(k));
filtin2 = rp(k)*sin(4*pi*f0*t(k)+2*theta(k)+2*omega(k));
z1 = [z1(2:end), filtin1];
z2 = [z2(2:end), filtin2];
omega(k+1)=omega(k)+uf*fliplr(h)*z1';
theta(k+1) = theta(k)+up*fliplr(h)*z2';
tp(k) = cos(4*pi*f0*t(k)+2*theta(k)+2*omega(k));
cos_synced(k)= cos(2*pi*f0*t(k)+theta(k)+omega(k)+pi);
end
%% demodulation
rx_demodI = rx.*cos_synced';
[n, f0,a0,w0] = firpmord([3500, 5000], [ 1 0], [0.01, 0.1], fs);
demod_LPF = firpm(n,f0,a0,w0);
rx_demodI = filter(demod_LPF,1,rx_demodI);
%%
rx_I = filter(psf,1,rx_demodI);

figure(3)
plot(cosm-cos_synced);
title('Difference between tx modulator and rx demodulator')
ylabel('Amplitude')
xlabel('Time (sec)')