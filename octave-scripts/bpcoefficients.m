% copied from https://ccrma.stanford.edu/~jos/sasp/Bandpass_Filter_Design_Example.html

fs = 20000;                 % sampling rate
F = [3000 4000 6000 8000];  % band limits
A = [0 1 0];                % band type: 0='stop', 1='pass'
dev = [0.0001 10^(0.1/20)-1 0.0001]; % ripple/attenuation spec
[M,Wn,beta,typ] = kaiserord(F,A,dev,fs);  % window parameters
b = fir1(M,Wn,typ,kaiser(M+1,beta),'noscale'); % filter design