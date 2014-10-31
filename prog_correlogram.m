clear
close all

% % Données
%   length_Signal = 512;
%   time = (0:length_Signal-1)'/length_Signal;
%   time_Sampling = median(diff(time));
%   data = cos(64*pi*time);
%   length_correlo = 2*length_Signal;
%   f_ech = 1/time_Sampling;

% Données
[data,f_ech] = audioread('fluteircam.wav');
[data,f_ech] = audioread('adroite.wav');


% sous-échantillonage
rapport = 1;
data = data(1:rapport:length(data));
f_ech = f_ech/rapport;

length_Signal = length(data);
time_Sampling = 1/f_ech;
length_correlo = 2048;
time = time_Sampling*(0:length_Signal-1);
% plot(data);


% Plafond pour les plot
fmax_plot = f_ech/2;
fmax_plot = 2500;
indice_plot = floor(length_correlo*fmax_plot/(f_ech/2));


% Decomposition en frames
frames_time = 0.04; % 40ms
frames_length = floor(frames_time*f_ech);
nFrames = (floor(length_Signal/frames_length))*2 - 1;
frames = zeros(nFrames,frames_length);
for frame = 1: nFrames
    frames(frame,:) = data(frames_length*(frame - 1)/2 + 1: frames_length*(frame + 1)/2);
end


for frame = 1:1:nFrames
    
    data = frames(frame,:);
    time_frame = time(frames_length*(frame - 1)/2 + 1: frames_length*(frame + 1)/2);
    
    % Calcul du corrélogramme
    [correlo,correloAxe] = correlogram(data,time_Sampling,length_correlo);
    
    
    %     % plot du corrélogramme simple
    %     figure
    %     subplot(2,2,1)
    %     plot(time_frame,data);
    %     grid on;xlabel('Time (s)');ylabel('Amplitude (a. u.)');
    %     subplot(2,2,3)
    %     plot(correloAxe(1:indice_plot),correlo(1:indice_plot));
    %     grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
    %     title('périodogramme');
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Avec une fenêtre de pondération
    windowSine = Window_Raised_Frac_Sine(frames_length,floor(frames_length/20),2,[0.1 1]);
    windowSine = windowSine';
    data_fen = data.*windowSine;
    
    [correlo_fen,correloAxe] = correlogram(data_fen,time_Sampling,length_correlo);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %     % plot du corrélogramme avec fenêtre
    %     subplot(2,2,2)
    %     plot(time_frame,data_fen);
    %     grid on;xlabel('Time (s)');ylabel('Amplitude (a. u.)');
    %     title('Avec une fenêtre de pondération');
    %     subplot(2,2,4)
    %     plot(correloAxe(1:indice_plot),correlo_fen(1:indice_plot));
    %     grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
    %     title('périodogramme');
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Estimateur de Daniell
    
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure
    % plot du signal
    subplot(2,2,1)
    plot(time_frame,data);
    grid on;xlabel('Time (s)');ylabel('Amplitude (a. u.)');
    title('Signal');
    
    % plot du corrélogramme simple
    subplot(2,2,3)
    plot(correloAxe(1:indice_plot),correlo(1:indice_plot));
    grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
    title('Correlogramme simple');
    
    % plot du corrélogramme avec estimateur de Daniell
    subplot(2,2,2)
    plot(correloAxe(1:indice_plot),correlo_dan(1:indice_plot));
    grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
    title('Estimateur de Daniell');
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Estimateur de Bartlett
    
    % nombre de segments :
    K = 4;
    % nombres d'échantillons par segment :
    M = floor(frames_length/K);
    
    correlo_bar = zeros(1,length_correlo);
    for i = 0:(K-1)
        [minicorrelo,correloAxe] = correlogram(data((i*M + 1):((i+1)*M)),...
                                               time_Sampling,length_correlo);
        correlo_bar = correlo_bar + minicorrelo;
    end
    correlo_bar = (1/K)*correlo_bar;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % plot du correlogramme avec estimateur de Bartlett
    subplot(2,2,4)
    plot(correloAxe(1:indice_plot),correlo_bar(1:indice_plot));
    grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
    title('Estimateur de Bartlett');
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Estimateur de Welsh
    
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % plot du corrélogramme avec estimateur de Welsh
    subplot(2,2,1)
    plot(correloAxe(1:indice_plot),correlo_wel(1:indice_plot));
    grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
    title('Estimateur de Welsh');
    
end

% passage de variables pour la reconstitution
length = length_correlo;
save 'D:\Cours Supélec\3A\analyse_spectrale\variables' length...
                                                       f_ech...
                                                       data...
                                                       time_Sampling...
                                                       nFrames...
                                                       frames_length...
                                                       frames...
                                                       time