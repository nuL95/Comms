% Author: Mark Blair
% 12/24/2024
% Basic communication system simulation, no phase/frequency tracking of
% carrier, timing recovery, or channel estimation The system is uses QAM4
% and a SRRC pulse shape
%% Simulation parameters and variables
Tb = 1e-6;
numBits = 100000;
beta = 0.7;
span = 18;
sps = 12;
fc = 3e5;
dBvec = 0:12;

noisePow = 10.^(-dBvec./10);
bitError = zeros(1,length(noisePow));
%% 
for kk = 1:length(noisePow)
bitstream = randi([0 1], 1 , numBits);
syms = qam4(bitstream);
Tx = syms;
noise = sqrt(noisePow(kk))*(randn(1, length(Tx))+1j*randn(1, length(Tx)));
Rx = Tx+noise;
bitRec = qam4demod(Rx);

bitError(kk) = sum(abs(bitRec-bitstream))/numBits;
end
semilogy(dBvec,bitError);
grid on
%Takes a vector of 0s and 1s and maps them to a QAM4
%constellation
function syms = qam4(bitstream)
    if rem(length(bitstream), 2) == 0
        symlength = length(bitstream)/2;
        syms = zeros(1, symlength);
    else
        bitstream = [bitstream 0];
        symlength = length(bitstream)/2;
        syms = zeros(1, symlength);
    end
    for ii = 1:length(syms)
        if isequal(bitstream((ii-1)*2+1:2*ii), [0 0])
            syms(ii) = 1 + j*1;
        elseif isequal(bitstream((ii-1)*2+1:2*ii), [1 1])
            syms(ii) = -1 - j*1;
        elseif isequal(bitstream((ii-1)*2+1:2*ii), [1 0])
            syms(ii) = 1 - j*1;
        elseif isequal(bitstream((ii-1)*2+1:2*ii), [0 1])
            syms(ii) = -1 + j*1;
        end
    end
end

%Hard decision decoder for QAM4
function bitsRec = qam4demod(Rx)
    bitsRec = zeros(1, length(Rx)*2);
    for ii = 1:length(Rx)
        if real(Rx(ii)) > 0 && imag(Rx(ii)) > 0
            bitsRec((ii-1)*2+1:2*ii) = [0 0];
        elseif real(Rx(ii)) < 0 && imag(Rx(ii)) < 0
            bitsRec((ii-1)*2+1:2*ii) = [1 1];
        elseif real(Rx(ii)) > 0 && imag(Rx(ii)) < 0
            bitsRec((ii-1)*2+1:2*ii) = [1 0];
        else
            bitsRec((ii-1)*2+1:2*ii) = [0 1];            
        end
    end
end

%Takes a list of parameters for a SRRC pulse and a symbol vector and shapes
%the pulse using the SRRC filter specified.
function ps = pulseshape(syms, beta, span, sps)
    b = rcosdesign(beta, span, sps, "sqrt");
    psR = conv(b, real(syms));
    psI = conv(b, imag(syms));
    ps = psR + 1j*psI;
end