clear
close all


% Données
[data,f_ech] = audioread('fluteircam.wav');


% sous-échantillonage
rapport = 1;
data = data(1:rapport:length(data));
f_ech = f_ech/rapport;

length_Signal = length(data);
time_Sampling = 1/f_ech;
length_fftr = 2048;
time = time_Sampling*(0:length_Signal-1);
% plot(data);


% Plafond pour les plot
fmax_plot = 2500;
indice_plot = floor(length_fftr*fmax_plot/(f_ech/2));


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
    
    %     figure;clf
    %     subplot(2,1,1)
    %     plot(time_frame,data);axis tight;grid on;xlabel('Time (s)');ylabel('Amplitude (a. u.)');
    %     subplot(2,1,2);hold on
    [fft_R,fft_Axe] = FFTR(data',time_Sampling,2*length_fftr);
    %     [fft_R_Max,fft_R_Idx] = max(fft_R);
    %     plot(fft_Axe,fft_R,'x');axis tight;grid on;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
    %     plot(fft_Axe(fft_R_Idx),fft_R(fft_R_Idx),'ro');
    %     title('Transformée de Fourier discrète');

end


% passage de variables pour la reconstitution
length = length_fftr;
save 'D:\Cours Supélec\3A\analyse_spectrale\variables' length...
                                                       f_ech...
                                                       data...
                                                       time_Sampling...
                                                       nFrames...
                                                       frames_length...
                                                       frames...
                                                       time