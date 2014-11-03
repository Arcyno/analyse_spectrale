function [perio,perioAxe] = periodogram(data,timeSamp,perioLength);

%% abscisses
freq_Sampling = 1/timeSamp;
axe_freq = (0.5*freq_Sampling/perioLength)*(0:perioLength-1);
perioAxe = axe_freq;


%% Calcul brutal du périodogramme
%   perio = zeros(1,perioLength);
%   for f = 1:perioLength
%       for k = 0:length(data) - 1
%           perio(f) = perio(f) + data(k+1)*exp(-j*2*pi*axe_freq(f)*k*timeSamp);
%       end
%       perio(f) = perio(f)*conj(perio(f))*timeSamp/length(data);
%   end


%% Calcul du périodogramme à l'aide d'une transformée de Fourier
transformee = fft(data,2*perioLength);
transformee = transformee(1:perioLength);
perio = transformee.*conj(transformee)*timeSamp/length(data);

end