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
% step_AGC = 0.01;
% AGC_len = 3e3;
% a = zeros(AGC_len,1); a(1) = 1;
% s = zeros(AGC_len,1);
% target_pow = 0.1661;
% lenavg = 10;
% avec = zeros(1,lenavg);
% for k = 1:AGC_len-1
%     s(k) = a(k)*rx_BB_I(k);
%     avec = [(s(k)^2-target_pow)*(s(k)^2)/a(k), avec(1:end-1)];
%     a(k+1) = a(k) - step_AGC*mean(avec);
% end
% rx_BB_I = rx_BB_I*mean(a(round(end/2):end));
% rx_BB_Q = rx_BB_Q*mean(a(round(end/2):end));
%% Carrier recovery
r_pll = tx.^2;
bpf_width = 20000;
bpf_freqs = [2*fc-bpf_width 2*fc-bpf_width/2 2*fc+bpf_width/2 2*fc+bpf_width];
[no,fo,mo,wo] = firpmord(bpf_freqs,[0 1 0], [0.1 0.01 0.1],fs);

pll_bpf = firpm(no,fo,mo,wo);

%We need to find the phase shift added by this bandpass filter to our
%frequency of interest, I haven't though of a good way to automate this
%yet.
bpf_ph_offset = -320.625*pi/180;

r_pll = filter(pll_bpf,1,r_pll);
step_phase = 0.03;
step_freq = 0.1;
theta = zeros(1,length(t));theta(1) = 0;
omega = zeros(1,length(t));omega(1) = 0;
for k = 1:length(t)
f1 = r_pll(k)*sin(4*pi*fc*t(k)+2*omega(k));
f2 = r_pll(k)*sin(4*pi*fc*t(k)+2*omega(k)+2*theta(k));
omega(k+1) = omega(k) - step_freq*f1';
theta(k+1) = theta(k) - step_phase*f2';
carrier_sync(k) = cos(2*pi*fc*t(k)+theta(k)+omega(k)+bpf_ph_offset);
end

rx = tx_dat.tx.*carrier_sync;
%% Timing Recovery