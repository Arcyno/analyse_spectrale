%% test de reconnaissance d'une sinusoide à amplitude variable.
%%%%% rmq : ordre bas -> un pic, ordre élevé -> une bande
%choisir entre variation exp et linéraire

close all

fe=32000;   %% fr\'equence d'\'echantillonnage  (en Hz)
tsig=12800;  %% longueur du signal               (en nombre d'\'echantillons)
f0=440;     %% fr\'equence de la sinuso\"{\i}de (en Hz)
amin=1;     %% amplitude min
amax=100;     %% amplitude max
ordre=10;  %% ordre du mod\`ele AR

%%intiialisation
a=amin;
xx = [1:tsig];


% %% variation linéaire
% da = (amax-amin)/tsig;
% for k=1:tsig
% a=a+da;
% xx(k)=a*sin(2*pi*f0/fe*k);                        %%% construction du signal
% end

%%% variation exp
da=log(amax/amin)/tsig;
for k=1:tsig
a=exp(log(amin)+da*k)
xx(k)=a*sin(2*pi*f0/fe*k);                        %%% construction du signal
end

%plot
figure(1)
plot(xx);


[aa, sigma2, ref, ff, mydsp] = mylevinsondurbin(xx,ordre,fe); %%% calcul du mod\`ele AR
[mmax, pmax] = max(mydsp);

%plot
figure(2)
labelx = sprintf('frequency %d', abs(ff(pmax)));
labely = sprintf('magnitude');

indice = floor(length(ff)/2);
hold on;
grid on;
plot(ff(indice:indice+1000),mydsp(indice:indice+1000),'linewidth',2);
xlabel(labelx,'fontsize',15);
ylabel(labely,'fontsize',15);
hold off;
drawnow;
