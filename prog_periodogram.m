clear
close all  

% % Données
%   length_Signal = 512;
%   time = (0:length_Signal-1)'/length_Signal;
%   time_Sampling = median(diff(time));
%   data = cos(64*pi*time);
%   length_perio = 2*length_Signal;
  
  % Données
  [data,fs] = audioread('fluteircam.wav');
  
  
  % sous-échantillonage
  rapport = 1;
  data = data(1:rapport:length(data));
  fs = fs/rapport;
  
  length_Signal = length(data);
  time_Sampling = 1/fs;
  length_perio = 2048;
  time = time_Sampling*(0:length_Signal-1);
  % plot(data);
  
  % Calcul du périodogramme
  [perio,perioAxe] = periodogram(data,time_Sampling,length_perio);
      
  
  % plot du périodogramme simple
  figure
  subplot(2,2,1)
  plot(time,data);
  grid on;xlabel('Time (s)');ylabel('Amplitude (a. u.)');
  subplot(2,2,3)
  plot(perioAxe,perio);
  grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
  title('périodogramme');

  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Avec une fenêtre de pondération
  windowSine = Window_Raised_Frac_Sine(length_Signal,floor(length_Signal/20),2,[0.1 1]);
  data_fen = data.*windowSine;
  
  [perio_fen,perioAxe] = periodogram(data_fen,time_Sampling,length_perio);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % plot du périodogramme avec fenêtre
  subplot(2,2,2)
  plot(time,data_fen);
  grid on;xlabel('Time (s)');ylabel('Amplitude (a. u.)');
  title('Avec une fenêtre de pondération');
  subplot(2,2,4)
  plot(perioAxe,perio_fen);
  grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
  title('périodogramme');
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Estimateur de Daniell
  
  p = 10;
%   data_perio_ext = zeros(length_perio + 2*p);
%   data_perio_ext((p + 1):(p + length_perio)) = perio;
%   perio_dan = zeros(length_perio + 2*p);
  perio_dan = zeros(length_perio,1);
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
  
  figure
  % plot du signal
  subplot(2,2,1)
  plot(time,data);
  grid on;xlabel('Time (s)');ylabel('Amplitude (a. u.)');
  title('Signal'); 
  
  % plot du périodogramme simple
  subplot(2,2,3)
  plot(perioAxe,perio);
  grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
  title('périodogramme simple');
  
  % plot du périodogramme avec estimateur de Daniell
  subplot(2,2,2)
  plot(perioAxe,perio_dan);
  grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
  title('Estimateur de Daniell');
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Estimateur de Bartlett
  
  % nombre de segments :
  K = 8;
  % nombres d'échantillons par segment :
  M = floor(length_Signal/K);
  
  perio_bar = zeros(length_perio,1);
  for i = 0:(K-1)
     [miniperio,perioAxe] = periodogram(data((i*M + 1):((i+1)*M)),...
                                        time_Sampling,length_perio);
     perio_bar = perio_bar + miniperio;
  end
  perio_bar = (1/K)*perio_bar;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % plot du périodogramme avec estimateur de Bartlett
  subplot(2,2,4)
  plot(perioAxe,perio_bar);
  grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
  title('Estimateur de Bartlett');
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Estimateur de Welsh
  
  % Décalage entre deux tranches
  S = 200;
  % Nombre de tranches
  Kpr = floor((length(data)-M)/S + 1);
  % Fenêtre
  windowSine = Window_Raised_Frac_Sine(M,floor(M/20),2,[0.1 1]);
  fen = windowSine;
  % Coeff de normalisation du à l'utilisation d'une fenêtre
  Norm = (fen')*fen;
  Norm = Norm*time_Sampling/M;
  
  perio_wel = zeros(length_perio,1);
  for i = 0:(Kpr-1)
      [miniperio,perioAxe] = periodogram(fen.*data((i*S + 1):(i*S + M)),...
                                        time_Sampling,length_perio);
      perio_wel = perio_wel + miniperio;
  end
  perio_wel = perio_wel/(Kpr*Norm);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % plot du périodogramme avec estimateur de Welsh
  subplot(2,2,1)
  plot(perioAxe,perio_wel);
  grid on;axis tight;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
  title('Estimateur de Welsh');