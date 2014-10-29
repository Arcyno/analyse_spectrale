clear
close all

% % Données
%   length_Signal = 512;
%   time = (0:length_Signal-1)'/length_Signal;
%   time_Sampling = median(diff(time));
%   data = cos(64*pi*time);
%   length_perio = 2*length_Signal;

% Données
[data,f_ech] = audioread('fluteircam.wav');


% sous-échantillonage
rapport = 1;
data = data(1:rapport:length(data));
f_ech = f_ech/rapport;

length_Signal = length(data);
time_Sampling = 1/f_ech;
length_perio = 2048;
time = time_Sampling*(0:length_Signal-1);
% plot(data);


% Plafond pour les plot
fmax_plot = 2500;
indice_plot = floor(length_perio*fmax_plot/(f_ech/2));


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
    
    % Calcul du périodogramme
    [perio,perioAxe] = periodogram(data,time_Sampling,length_perio);
    
    
    %     % plot du périodogramme simple
    %     figure
    %     subplot(2,2,1)
    %     plot(time_frame,data);
    %     grid on;xlabel('Time (s)');ylabel('Amplitude (a. u.)');
    %     subplot(2,2,3)
    %     plot(perioAxe(1:indice_plot),perio(1:indice_plot));
    %     grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
    %     title('périodogramme');
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Avec une fenêtre de pondération
    windowSine = Window_Raised_Frac_Sine(frames_length,floor(frames_length/20),2,[0.1 1]);
    windowSine = windowSine';
    data_fen = data.*windowSine;
    
    [perio_fen,perioAxe] = periodogram(data_fen,time_Sampling,length_perio);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %     % plot du périodogramme avec fenêtre
    %     subplot(2,2,2)
    %     plot(time_frame,data_fen);
    %     grid on;xlabel('Time (s)');ylabel('Amplitude (a. u.)');
    %     title('Avec une fenêtre de pondération');
    %     subplot(2,2,4)
    %     plot(perioAxe(1:indice_plot),perio_fen(1:indice_plot));
    %     grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
    %     title('périodogramme');
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Estimateur de Daniell
    
    p = 5;
    %   data_perio_ext = zeros(length_perio + 2*p);
    %   data_perio_ext((p + 1):(p + length_perio)) = perio;
    %   perio_dan = zeros(length_perio + 2*p);
    perio_dan = zeros(1,length_perio);
    for i = 1:length_perio
        for n = (i - p):(i + p)
            %           perio_dan(p+i) = perio_dan(p+i) + data_perio_ext(p + n);
            if(n>0 && n<length_perio+1)
                perio_dan(i) = perio_dan(i) + perio(n);
            end
        end
    end
    %   perio_dan = perio_dan((10 + 1):(10 + length_perio));
    perio_dan = (1/(2*p + 1))*perio_dan;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %figure
    % plot du signal
    subplot(2,2,1)
    plot(time_frame,data);
    grid on;xlabel('Time (s)');ylabel('Amplitude (a. u.)');
    title('Signal');
    
    % plot du périodogramme simple
    subplot(2,2,3)
    plot(perioAxe(1:indice_plot),perio(1:indice_plot));
    grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
    title('périodogramme simple');
    
    % plot du périodogramme avec estimateur de Daniell
    subplot(2,2,2)
    plot(perioAxe(1:indice_plot),perio_dan(1:indice_plot));
    grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
    title('Estimateur de Daniell');
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Estimateur de Bartlett
    
    % nombre de segments :
    K = 4;
    % nombres d'échantillons par segment :
    M = floor(frames_length/K);
    
    perio_bar = zeros(1,length_perio);
    for i = 0:(K-1)
        [miniperio,perioAxe] = periodogram(data((i*M + 1):((i+1)*M)),...
            time_Sampling,length_perio);
        perio_bar = perio_bar + miniperio;
    end
    perio_bar = (1/K)*perio_bar;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % plot du périodogramme avec estimateur de Bartlett
    subplot(2,2,4)
    plot(perioAxe(1:indice_plot),perio_bar(1:indice_plot));
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
    
    perio_wel = zeros(1,length_perio);
    for i = 0:(Kpr-1)
        [miniperio,perioAxe] = periodogram(fen.*data((i*S + 1):(i*S + M)),...
            time_Sampling,length_perio);
        perio_wel = perio_wel + miniperio;
    end
    % Coeff de normalisation du à l'utilisation d'une fenêtre
    Norm = fen*(fen');
    Norm = Norm*time_Sampling/M;
    perio_wel = perio_wel/(Kpr*Norm);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % plot du périodogramme avec estimateur de Welsh
    subplot(2,2,1)
    plot(perioAxe(1:indice_plot),perio_wel(1:indice_plot));
    grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
    title('Estimateur de Welsh');
    
end