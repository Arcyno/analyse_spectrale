clear
close all


%% Paramètres

length_Signal = 2048;
% time = (0:length_Signal-1)/length_Signal;
% time_Sampling = median(diff(time))
length_correlo = length_Signal;
f_ech = 8000;
time_Sampling = 1/f_ech;
time = time_Sampling*(0:length_Signal-1);
f0 = 440;


%% Données

% Sinusoide pure
data = cos(f0*2*pi*time);
% Deux raies proches // sinusoide à amplitude variable
data = cos(f0*2*pi*time) + cos((f0+5)*2*pi*time);
% Une sinusoide et du bruit
bruit_blanc = rand(1,length_Signal);
bruit_gaussien = randn(1,length_Signal);
bruit = bruit_gaussien*2;
data = cos(f0*2*pi*time) + bruit;
% Sinusoide de fréquence variable
f = f0/2 + f0*[1:length_Signal]/length_Signal;
data = cos(2*pi*f.*time);


%% Plot du signal

plot(time, data);
grid on;xlabel('Time (s)');ylabel('Amplitude (a. u.)');
title('Signal');


%% Bornes pour les plot des correlogrammes

fmin_plot = 0;
fmax_plot = f_ech/2;
fmin_plot = 200;
fmax_plot = 600;
indice_plot = floor(length_correlo*fmax_plot/(f_ech/2));
indice_plot2 = floor(length_correlo*fmin_plot/(f_ech/2));


%% Calcul du périodogramme

[correlo,correloAxe] = correlogram(data,time_Sampling,length_correlo);


%% Avec une fenêtre de pondération

windowSine = Window_Raised_Frac_Sine(length_Signal,floor(length_Signal/20),2,[0.1 1]);
windowSine = windowSine';
data_fen = data.*windowSine;

[correlo_fen,correloAxe] = correlogram(data_fen,time_Sampling,length_correlo);

%     % plot du périodogramme avec fenêtre
%     subplot(2,2,2)
%     plot(time_frame,data_fen);
%     grid on;xlabel('Time (s)');ylabel('Amplitude (a. u.)');
%     title('Avec une fenêtre de pondération');
%     subplot(2,2,4)
%     plot(correloAxe(indice_plot2:indice_plot),correlo_fen(indice_plot2:indice_plot));
%     grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
%     title('correlogramme');


%% Estimateur de Daniell

p = 5;
%   data_correlo_ext = zeros(length_correlo + 2*p);
%   data_correlo_ext((p + 1):(p + length_correlo)) = correlo;
%   correlo_dan = zeros(length_correlo + 2*p);
correlo_dan = zeros(1,length_correlo);
for i = 1:length_correlo
    for n = (i - p):(i + p)
        %           correlo_dan(p+i) = correlo_dan(p+i) + data_correlo_ext(p + n);
        if(n>0 && n<length_correlo+1)
            correlo_dan(i) = correlo_dan(i) + correlo(n);
        end
    end
end
%   correlo_dan = correlo_dan((10 + 1):(10 + length_correlo));
correlo_dan = (1/(2*p + 1))*correlo_dan;


%% Estimateur de Bartlett

% nombre de segments :
K = 4;
% nombres d'échantillons par segment :
M = floor(length_Signal/K);

correlo_bar = zeros(1,length_correlo);
for i = 0:(K-1)
    [minicorrelo,correloAxe] = correlogram(data((i*M + 1):((i+1)*M)),...
        time_Sampling,length_correlo);
    correlo_bar = correlo_bar + minicorrelo;
end
correlo_bar = (1/K)*correlo_bar;


%% Estimateur de Welsh

% Décalage entre deux tranches
S = 20;
% Nombre de tranches
Kpr = floor((length(data)-M)/S + 1);
% Fenêtre
windowSine = Window_Raised_Frac_Sine(M,floor(M/20),2,[0.1 1]);
fen = windowSine';

correlo_wel = zeros(1,length_correlo);
for i = 0:(Kpr-1)
    [minicorrelo,correloAxe] = correlogram(fen.*data((i*S + 1):(i*S + M)),...
        time_Sampling,length_correlo);
    correlo_wel = correlo_wel + minicorrelo;
end
% Coeff de normalisation du à l'utilisation d'une fenêtre
Norm = fen*(fen');
Norm = Norm*time_Sampling/M;
correlo_wel = correlo_wel/(Kpr*Norm);


%% Plots

figure

% plot du correlogramme simple
subplot(2,2,1)
plot(correloAxe(indice_plot2:indice_plot),correlo(indice_plot2:indice_plot));
grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
title('correlogramme simple');

% plot du correlogramme avec estimateur de Daniell
subplot(2,2,2)
plot(correloAxe(indice_plot2:indice_plot),correlo_dan(indice_plot2:indice_plot));
grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
title('Estimateur de Daniell');

% plot du correlogramme avec estimateur de Bartlett
subplot(2,2,3)
plot(correloAxe(indice_plot2:indice_plot),correlo_bar(indice_plot2:indice_plot));
grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
title('Estimateur de Bartlett');

% plot du correlogramme avec estimateur de Welsh
subplot(2,2,4)
plot(correloAxe(indice_plot2:indice_plot),correlo_wel(indice_plot2:indice_plot));
grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
title('Estimateur de Welsh');


%% passage de variables pour la reconstitution
%
% length = length_correlo;
% save 'D:\Cours Supélec\3A\analyse_spectrale\variables' length...
%                                                        f_ech...
%                                                        time_Sampling...
%                                                        nFrames...
%                                                        frames_length...
%                                                        frames...
%                                                        time