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
% Pour la détection de la fréquence principale
frames_freq = zeros(nFrames,1);


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
    % Detection de la fréquence principale
    [nom_quelconque,f_main] = max(perio);
    frames_freq(frame) = perioAxe(f_main);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


% Lissage des fréquences
nb_voisins = 5;
frames_freq = (1/nb_voisins)*conv(ones(1,nb_voisins),frames_freq);

sortie = zeros(1,nFrames*frames_length);

%% ajout cote a cote
phase_sup = 0;
for frame = 0:nFrames-1
    sortie(frame*frames_length/2+1:(frame+1)*frames_length/2) =...
        cos(2*pi*frames_freq(frame+1)/f_ech*[0:frames_length/2-1]+phase_sup);
    phase_sup = 2*pi*frames_freq(frame+1)/f_ech*(frames_length/2-1)+phase_sup;
end

%% superposition
% phase_sup = 0;
% phase_sup2 = 0;
% phase_sup3 = 0;
% phase_sup4 = 0;
% fen = hamming(frames_length);
% for frame = 0:nFrames-1
%     sortie(frame*frames_length/2+1:frame*frames_length/2+frames_length) =...
%         sortie(frame*frames_length/2+1:frame*frames_length/2+frames_length) + ...
%         cos(2*pi*frames_freq(frame+1)/f_ech*[0:frames_length-1]+phase_sup).*fen'+ ...
%         cos(4*pi*frames_freq(frame+1)/f_ech*[0:frames_length-1]+phase_sup2).*(fen/4)'+ ...
%         cos(6*pi*frames_freq(frame+1)/f_ech*[0:frames_length-1]+phase_sup3).*(fen/8)'+ ...
%         cos(8*pi*frames_freq(frame+1)/f_ech*[0:frames_length-1]+phase_sup4).*(fen/16)';
%     phase_sup = 2*pi*frames_freq(frame+1)/f_ech*(frames_length-1)+phase_sup;
% %     phase_sup2 = 4*pi*frames_freq(frame+1)/f_ech*(frames_length-1)+phase_sup2;
% %     phase_sup3 = 6*pi*frames_freq(frame+1)/f_ech*(frames_length-1)+phase_sup3;
% %     phase_sup4 = 8*pi*frames_freq(frame+1)/f_ech*(frames_length-1)+phase_sup4;
%     phase_sup2 = phase_sup;
%     phase_sup3 = phase_sup;
%     phase_sup4 = phase_sup;
% end

figure
plot(sortie(1:3*frames_length));
% soundsc(sortie,f_ech);