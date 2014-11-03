close all;

%chargement du fichier
[son,f_ech]= wavread('fluteircam.wav');

% Parametres
for ordre_lpc = [10,50,150,300]
    %ordre_lpc = i*50;
    frames_time = 0.032;
    frames_length = floor(frames_time*f_ech);
    [coeffs_lpc,sigma_frames] = mylpc(f_ech,son,frames_length,ordre_lpc);
    nFrames = size(coeffs_lpc,1);
    frames_freq = zeros(nFrames,1);
    'fini lpc'
    %%% densit\'e spectrale de puissance
    %for frame = 1:nFrames
    for frame = 350:350
        %%% affichage dsp
        
        interm2=-j*2*pi/f_ech*[1:ordre_lpc];
        df=1;      %%% la dsp est calcul\'ee tous les df Hz
        
        ff=-f_ech/4:df:f_ech/4;
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
        
        %%% dÃ©tection max
        [g,f] = max(mydsp);
        frames_freq(frame) = -ff(f);
    end
    'fini affichage'
    
    
    sortie = zeros(1,nFrames*frames_length);
    
    %% ajout cote a cote
    phase_sup = 0;
    % for frame = 0:nFrames-1
    %     sortie(frame*frames_length/2+1:(frame+1)*frames_length/2) =...
    %         cos(2*pi*frames_freq(frame+1)/f_ech*[0:frames_length/2-1]+phase_sup);
    %     phase_sup = 2*pi*frames_freq(frame+1)/f_ech*(frames_length/2-1)+phase_sup;
    % end
    
    %% superposition
    phase_sup = 0;
    fen = hamming(frames_length);
    for frame = 0:nFrames-1
        sortie(frame*frames_length/2+1:frame*frames_length/2+frames_length) =...
            sortie(frame*frames_length/2+1:frame*frames_length/2+frames_length) + ...
            cos(2*pi*frames_freq(frame+1)/f_ech*[0:frames_length-1]+phase_sup).*fen'+ ...
            cos(4*pi*frames_freq(frame+1)/f_ech*[0:frames_length-1]+phase_sup).*(fen/4)'+ ...
            cos(6*pi*frames_freq(frame+1)/f_ech*[0:frames_length-1]+phase_sup).*(fen/8)'+ ...
            cos(8*pi*frames_freq(frame+1)/f_ech*[0:frames_length-1]+phase_sup).*(fen/16)';
        phase_sup = 2*pi*frames_freq(frame+1)/f_ech*(frames_length-1)+phase_sup;
    end
    figure(4)
    if(ordre_lpc==10)
        subplot(2,2,1)
    elseif(ordre_lpc==50)
        subplot(2,2,2)
    elseif(ordre_lpc==150)
        subplot(2,2,3)
    elseif(ordre_lpc==300)
        subplot(2,2,4)
    end
    labely = sprintf('magnitude');
    labelx = sprintf('fréquence (en Hz)');
    label = sprintf('ordre p = %0.1d', ordre_lpc);
    hold off;
plot(0);
    hold on;
    %plot(frames_freq);
    plot(ff(6001:10000),mydsp(6001:10000));
    xlabel(labelx,'fontsize',15);
    ylabel(labely,'fontsize',15);
    title(label,'Fontsize',20);
    hold off;
end
