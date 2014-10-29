%% test de reconnaissance d'une sinusoide bruitée.
close all


fe=32000;   %% fr\'equence d'\'echantillonnage  (en Hz)
f0=440;     %% fr\'equence de la sinuso\"{\i}de (en Hz)
tsig=1280;  %% longueur du signal               (en nombre d'\'echantillons)
ordre=150;  %% ordre du mod\`ele AR
n_boucle = 20;

bruit=0;

for k=0:n_boucle
bruit = (rand(1,tsig)*-0.5)*k/5; %génération du bb
xx=sin(2*pi*f0/fe*[1:tsig])+bruit;                        %%% construction du signal
%plot signal
figure(1)
subplot(4,5,k+1);
plot(xx);
[aa, sigma2, ref, ff, mydsp] = mylevinsondurbin(xx,ordre,fe); %%% calcul du mod\`ele AR
[mmax, pmax] = max(mydsp);

%plot
figure(2)
label = sprintf('frequency %d', abs(ff(pmax)))
indice = floor(length(ff)/2);
subplot(4,5,k+1);
hold on;
plot(ff(indice:indice+1000),mydsp(indice:indice+1000),'linewidth',2);
xlabel(label,'fontsize',15);
ylabel('magnitude','fontsize',20);
hold off;
drawnow;
end