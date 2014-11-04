clear
close all

%load 'D:\Cours Supélec\3A\analyse_spectrale\variables'

%% Données
[data,f_ech] = audioread('fluteircam.wav');
% [data,f_ech] = audioread('adroite.wav');


length_Signal = length(data);
time_Sampling = 1/f_ech;
length = 2048;
time = time_Sampling*(0:length_Signal-1);


%% Plafond pour les plot
fmax_plot = 2500;
indice_plot = floor(length*fmax_plot/(f_ech/2));


%% Decomposition en frames
frames_time = 0.04; % 40ms
frames_length = floor(frames_time*f_ech);
nFrames = (floor(length_Signal/frames_length))*2 - 1;
frames = zeros(nFrames,frames_length);
for frame = 1: nFrames
    frames(frame,:) = data(frames_length*(frame - 1)/2 + 1: frames_length*(frame + 1)/2);
end

%Pour le stockage de la fréquence principale
frames_freq = zeros(nFrames,1);
%Pour le stockage de l'enveloppe spectrale
frames_DSP = zeros(nFrames,length);

for frame = 1:1:nFrames
    
    data = frames(frame,:);
    time_frame = time(frames_length*(frame - 1)/2 + 1):...
        frames_length*(frame + 1)/2;
    
    % Calcul du périodogramme
    [perio,perioAxe] = periodogram(data,time_Sampling,length);
    
    % Calcul du corrélogramme
    [correlo,correloAxe] = periodogram(data,time_Sampling,length);
    
    % Calcul de la FFT
    [fft_R,fft_Axe] = FFTR(data',time_Sampling,2*length);
    
    % Choix entre les méthodes
    resultat = perio;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Detection de la fréquence principale
    [nom_quelconque,f_main] = max(resultat);
    frames_freq(frame) = perioAxe(f_main);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Stockage de l'enveloppe spectrale
    frames_DSP(frame,:) = resultat;
    
end


%% Lissage des fréquences
nb_voisins = 3;
frames_freq = (1/nb_voisins)*conv(ones(1,nb_voisins),frames_freq);


%% Reconstitution

% création d'un vecteur pour le résultat de la reconstitution
sortie = zeros(1,nFrames*frames_length);

% ajout cote a cote
phase_sup = 0;
% for frame = 0:nFrames-1
%     sortie(frame*frames_length/2+1:(frame+1)*frames_length/2) =...
%         cos(2*pi*frames_freq(frame+1)/f_ech*[0:frames_length/2-1]+phase_sup);
%     phase_sup = 2*pi*frames_freq(frame+1)/f_ech*(frames_length/2-1)+phase_sup;
% end


% ajout cote a cote + harmoniques
phase_sup = 0;
phase_sup2 = 0;
phase_sup3 = 0;
phase_sup4 = 0;
for frame = 0:nFrames-1
    sortie(frame*frames_length/2+1:(frame+1)*frames_length/2) =...
        cos(2*pi*frames_freq(frame+1)/f_ech*[0:frames_length/2-1]+phase_sup)+ ...
        cos(4*pi*frames_freq(frame+1)/f_ech*[0:frames_length/2-1]+phase_sup2)*(1/2)'+ ...
        cos(6*pi*frames_freq(frame+1)/f_ech*[0:frames_length/2-1]+phase_sup3)*(1/3)'+ ...
        cos(8*pi*frames_freq(frame+1)/f_ech*[0:frames_length/2-1]+phase_sup4)*(1/4)';
    phase_sup = 2*pi*frames_freq(frame+1)/f_ech*(frames_length/2-1)+phase_sup;
    phase_sup2 = 4*pi*frames_freq(frame+1)/f_ech*(frames_length/2-1)+phase_sup2;
    phase_sup3 = 6*pi*frames_freq(frame+1)/f_ech*(frames_length/2-1)+phase_sup3;
    phase_sup4 = 8*pi*frames_freq(frame+1)/f_ech*(frames_length/2-1)+phase_sup4;
end

% superposition
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
figure
plot(frames_freq);
title('partition de flute');
soundsc(sortie,f_ech);