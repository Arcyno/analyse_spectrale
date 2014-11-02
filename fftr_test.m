clear
close all


%% Paramètres

length_Signal = 2048;
% time = (0:length_Signal-1)/length_Signal;
% time_Sampling = median(diff(time))
length_fftr = length_Signal;
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


%% Bornes pour les plot des fftr

fmin_plot = 0;
fmax_plot = f_ech/2;
fmin_plot = 200;
fmax_plot = 600;
indice_plot = floor(length_fftr*fmax_plot/(f_ech/2));
indice_plot2 = floor(length_fftr*fmin_plot/(f_ech/2));


%% Calcul de la fftr

[fftr,fftrAxe] = FFTR(data',time_Sampling,'n',length_fftr);


%% Avec une fenêtre de pondération

windowSine = Window_Raised_Frac_Sine(length_Signal,floor(length_Signal/20),2,[0.1 1]);
windowSine = windowSine';
data_fen = data.*windowSine;

[fftr_fen,fftrAxe] = FFTR(data_fen',time_Sampling,'n',length_fftr);

%     % plot de la fftr avec fenêtre
%     subplot(2,2,2)
%     plot(time_frame,data_fen);
%     grid on;xlabel('Time (s)');ylabel('Amplitude (a. u.)');
%     title('Avec une fenêtre de pondération');
%     subplot(2,2,4)
%     plot(fftrAxe(indice_plot2:indice_plot),fftr_fen(indice_plot2:indice_plot));
%     grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
%     title('fftr');


%% Estimateur de Daniell

p = 5;
%   data_fftr_ext = zeros(length_fftr + 2*p);
%   data_fftr_ext((p + 1):(p + length_fftr)) = fftr;
%   fftr_dan = zeros(length_fftr + 2*p);
fftr_dan = zeros(1,length_fftr);
for i = 1:length_fftr
    for n = (i - p):(i + p)
        %           fftr_dan(p+i) = fftr_dan(p+i) + data_fftr_ext(p + n);
        if(n>0 && n<length_fftr+1)
            fftr_dan(i) = fftr_dan(i) + fftr(n);
        end
    end
end
%   fftr_dan = fftr_dan((10 + 1):(10 + length_fftr));
fftr_dan = (1/(2*p + 1))*fftr_dan;


%% Estimateur de Bartlett

% nombre de segments :
K = 4;
% nombres d'échantillons par segment :
M = floor(length_Signal/K);

% fftr_bar = zeros(1,length_fftr);
% for i = 0:(K-1)
%     [minifftr,fftrAxe] = FFTR((data((i*M + 1):((i+1)*M)))',...
%                               time_Sampling,'n',length_fftr);
%     fftr_bar = fftr_bar + minifftr;
% end
% fftr_bar = (1/K)*fftr_bar;


%% Estimateur de Welsh

% Décalage entre deux tranches
S = 20;
% Nombre de tranches
Kpr = floor((length(data)-M)/S + 1);
% Fenêtre
windowSine = Window_Raised_Frac_Sine(M,floor(M/20),2,[0.1 1]);
fen = windowSine';

% fftr_wel = zeros(1,length_fftr);
% for i = 0:(Kpr-1)
%     [minifftr,fftrAxe] = FFTR((fen.*data((i*S + 1):(i*S + M)))',...
%                                time_Sampling,'n',length_fftr);
%     fftr_wel = fftr_wel + minifftr;
% end
% % Coeff de normalisation du à l'utilisation d'une fenêtre
% Norm = fen*(fen');
% Norm = Norm*time_Sampling/M;
% fftr_wel = fftr_wel/(Kpr*Norm);


%% Plots

figure

% plot du périodogramme simple
subplot(2,2,1)
plot(fftrAxe(indice_plot2:indice_plot),fftr(indice_plot2:indice_plot));
grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
title('FFTR simple');

% plot du périodogramme avec estimateur de Daniell
subplot(2,2,2)
plot(fftrAxe(indice_plot2:indice_plot),fftr_dan(indice_plot2:indice_plot));
grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
title('Estimateur de Daniell');

% % plot du périodogramme avec estimateur de Bartlett
% subplot(2,2,3)
% plot(fftrAxe(indice_plot2:indice_plot),fftr_bar(indice_plot2:indice_plot));
% grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
% title('Estimateur de Bartlett');
% 
% % plot du périodogramme avec estimateur de Welsh
% subplot(2,2,4)
% plot(fftrAxe(indice_plot2:indice_plot),fftr_wel(indice_plot2:indice_plot));
% grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
% title('Estimateur de Welsh');


%% passage de variables pour la reconstitution
%
% length = length_fftr;
% save 'D:\Cours Supélec\3A\analyse_spectrale\variables' length...
%                                                        f_ech...
%                                                        time_Sampling...
%                                                        nFrames...
%                                                        frames_length...
%                                                        frames...
%                                                        time