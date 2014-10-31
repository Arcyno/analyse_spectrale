clear
close all

load 'D:\Cours Supélec\3A\analyse_spectrale\variables'


% plot(data);


% Plafond pour les plot
fmax_plot = 2500;
indice_plot = floor(length*fmax_plot/(f_ech/2));


% Pour le stockage de la fréquence principale
frames_freq = zeros(nFrames,1);


for frame = 1:1:nFrames
    
    data = frames(frame,:);
    time_frame = time(frames_length*(frame - 1)/2 + 1):...
                      frames_length*(frame + 1)/2;
    
    % Calcul du périodogramme
    [perio,perioAxe] = periodogram(data,time_Sampling,length);
    
    % Calcul du corrélogramme
    [correlo,correloAxe] = periodogram(data,time_Sampling,length);
    
    % Choix entre les méthodes
    resultat = correlo;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Detection de la fréquence principale
    [nom_quelconque,f_main] = max(resultat);
    frames_freq(frame) = perioAxe(f_main);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end


% Lissage des fréquences
nb_voisins = 5;
frames_freq = (1/nb_voisins)*conv(ones(1,nb_voisins),frames_freq);

% création d'un vecteur pour le résultat de la reconstitution
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
soundsc(sortie,f_ech);