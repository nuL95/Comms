%% Demodulation via downsampling, the ratio of the sampling frequency to modulation frequency needs to be an integer.
clear;close all;
%% system and signal parameters
fs = 1e5;
fsinc = 3e3;
fcos = 2.5e4;
N = 10000;
w = linspace(-fs/2,fs/2,N);
t = -(N/2)/fs:1/fs:(N/2)/fs-1/fs;
%% modulation
sxs = sinc(fsinc*t);
figure(1)
plot(w,abs(fftshift(fft(sxs,N))))
title('FFT magnitude of baseband signal')
ylabel('Magnitude')
xlabel('Freq (hz)')
sc = cos(2*pi*fcos*t);
smod = sxs.*sc;
figure(2)
plot(w,abs(fftshift(fft(smod,N))))
title('FFT magnitude of passband signal')
ylabel('Magnitude')
xlabel('Freq (hz)')
[n,fo,ao,wo] = firpmord([2500 10000],[1 0],[.001 .01], fs);
lpf = firpm(n,fo,ao,wo);

s_downsampled = zeros(1,N);
s_downsampled(1:4:end) = 1;
zt = smod.*s_downsampled;

ds = filter(lpf,1,zt);
figure(3)
plot(w,abs(fftshift(fft(ds,N))))
title('FFT magnitude of demodulated signal')
ylabel('Magnitude')
xlabel('Freq (hz)')