%% test de reconnaissance d'une sinusoide bruitée.
close all


fe=32000;   %% fr\'equence d'\'echantillonnage  (en Hz)
f0=440;     %% fr\'equence de la sinuso\"{\i}de (en Hz)
tsig=1280;  %% longueur du signal               (en nombre d'\'echantillons)
n_boucle = 3;

bruit=0;

ordre=50;  %% ordre du mod\`ele AR
for k=0:n_boucle-1
bruit = randn(1,tsig)*2*k; %génération du bb
xx=sin(2*pi*f0/fe*[1:tsig])+bruit;                        %%% construction du signal
%plot signal
figure(1)
subplot(2,3,k+1);
plot(xx);
[aa, sigma2, ref, ff, mydsp] = mylevinsondurbin(xx,ordre,fe); %%% calcul du mod\`ele AR
[mmax, pmax] = max(mydsp);

%plot
figure(2)
label = sprintf('sigma2 = %0.1d ; p = 100', k*2);
indice = floor(length(ff)/2);
subplot(2,3,k+1);
hold on;
plot(ff(indice:indice+1000),mydsp(indice:indice+1000),'linewidth',2);
xlabel('frequency (in Hz)','fontsize',15);
ylabel('magnitude','fontsize',15);
title(label,'Fontsize',20);
hold off;
drawnow;
end

ordre=300;  %% ordre du mod\`ele AR
for k=0:n_boucle-1
bruit = randn(1,tsig)*2*k; %génération du bb
xx=sin(2*pi*f0/fe*[1:tsig])+bruit;                        %%% construction du signal
%plot signal
figure(1)
subplot(2,3,k+1);
plot(xx);
[aa, sigma2, ref, ff, mydsp] = mylevinsondurbin(xx,ordre,fe); %%% calcul du mod\`ele AR
[mmax, pmax] = max(mydsp);

%plot
figure(2)
label = sprintf('sigma2 = %0.1d ; p = 300', k*2);
indice = floor(length(ff)/2);
subplot(2,3,k+4);
hold on;
plot(ff(indice:indice+1000),mydsp(indice:indice+1000),'linewidth',2);
xlabel('frequency (in Hz)','fontsize',15);
ylabel('magnitude','fontsize',15);
title(label,'Fontsize',20);
hold off;
drawnow;
end