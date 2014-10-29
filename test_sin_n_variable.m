%% test de reconnaissance d'une sinusoide, le nb de point est variable.
%%%%% rmq : plus l'ordre est bas mieux ça fonctionne !
close all

fe=32000;   %% fr\'equence d'\'echantillonnage  (en Hz)
f0=440;     %% fr\'equence de la sinuso\"{\i}de (en Hz)
tsig=1280;  %% longueur du signal               (en nombre d'\'echantillons)
ordre=150;  %% ordre du mod\`ele AR
n_boucle = 20;


for k=1:n_boucle
tsig_coupe=floor(tsig/k);
xx=sin(2*pi*f0/fe*[1:tsig_coupe]);                        %%% construction du signal
[aa, sigma2, ref, ff, mydsp] = mylevinsondurbin(xx,ordre,fe); %%% calcul du mod\`ele AR
[mmax, pmax] = max(mydsp);

%plot
figure(1)
labelx = sprintf('frequency %d', abs(ff(pmax)))
labely = sprintf('magnitude %d', tsig_coupe)

indice = floor(length(ff)/2);
subplot(4,5,k);
hold on;
plot(ff(indice:indice+1000),mydsp(indice:indice+1000),'linewidth',2);
xlabel(labelx,'fontsize',15);
ylabel(labely,'fontsize',15);
hold off;
drawnow;
end