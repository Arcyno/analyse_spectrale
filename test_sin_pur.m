%% test de reconnaissance d'une sinusoide pure.


fe=32000;   %% fr\'equence d'\'echantillonnage  (en Hz)
f0=440;     %% fr\'equence de la sinuso\"{\i}de (en Hz)
tsig=1280;  %% longueur du signal               (en nombre d'\'echantillons)
ordre=150;  %% ordre du mod\`ele AR


xx=sin(2*pi*f0/fe*[1:tsig]);                        %%% construction du signal

[aa, sigma2, ref, ff, mydsp] = mylevinsondurbin(xx,ordre,fe); %%% calcul du mod\`ele AR
[mmax, pmax] = max(mydsp);
'frequence max'
abs(ff(pmax))
'erreur'
f0-abs(ff(pmax))
