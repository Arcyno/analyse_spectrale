close all;

%chargement du fichier
[son,f_ech]= wavread('fluteircam.wav');

% Parametres
ordre_lpc = 100;
frames_time = 0.04;
frames_length = floor(frames_time*f_ech);
[coeffs_lpc,sigma_frames] = mylpc(f_ech,son,frames_length,ordre_lpc);
nFrames = size(coeffs_lpc,1);
frames_freq = zeros(nFrames,1);

%%% densit\'e spectrale de puissance
for frame = 1:nFrames
    %%% affichage dsp
    interm2=-j*2*pi/f_ech*[1:ordre_lpc];
    df=0.9765625;      %%% la dsp est calcul\'ee tous les df Hz
    ff=-f_ech/2:df:f_ech/2;
    
    interm3=interm2'*ff;
    interm=1.+coeffs_lpc(frame,2:ordre_lpc+1)*exp(interm3);
    mydsp = sigma_frames(frame)./(interm.*conj(interm));
%     figure(1);
%     clf;
%     grid on;
%     hold on;
%     plot(ff,mydsp,'linewidth',2);
%     xlabel('frequency (in Hz)','fontsize',20);
%     ylabel('magnitude','fontsize',20);
%     hold off;
%     drawnow;
    
    %%% détection max
    [g,f] = max(mydsp);
    frames_freq(frame) = ff(f);
end


sortie = zeros(1,nFrames);
for frame = 0:nFrames-1
    sortie(frame*frames_length:frame*frames_length+frames_length/2) =...
                 cos(2*pi*frames_freq(frame)/f_ech*[1:frames_length/2]);
end