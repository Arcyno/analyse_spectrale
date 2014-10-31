%% test de reconnaissance d'une sinusoide à amplitude variable.
%%%%% rmq : ordre bas -> un pic, ordre élevé -> une bande
%choisir entre variation exp et linéraire

%close all

fe=32000;   %% fr\'equence d'\'echantillonnage  (en Hz)
tsig=1280;  %% longueur du signal               (en nombre d'\'echantillons)
f0=440;     %% fr\'equence de la sinuso\"{\i}de (en Hz)
amin=1;     %% amplitude min
amax=100;     %% amplitude max
ordre=10;  %% ordre du mod\`ele AR

%%intiialisation
a=amin;
xx = [1:tsig];


%% variation linéaire
da = (amax-amin)/tsig;
for k=1:tsig
a=a+da;
xx(k)=a*sin(2*pi*f0/fe*k);                        %%% construction du signal
end

%%% variation exp
% da=log(amax/amin)/tsig;
% for k=1:tsig
% a=exp(log(amin)+da*k);
% xx(k)=a*sin(2*pi*f0/fe*k);                        %%% construction du signal
% end


%%% variation 'sin'
% da=log(amax/amin)/tsig;
% for k=1:tsig
% a=sin(6*pi*k)+sin(11*pi*k)+sin(21.5*pi*k);
% xx(k)=a*sin(2*pi*f0/fe*k);                        %%% construction du signal
% end




[aa, sigma2, ref, ff, mydsp] = mylevinsondurbin(xx,ordre,fe); %%% calcul du mod\`ele AR
[mmax, pmax] = max(mydsp);
%plot
% figure(1)
% plot(xx);


%plot
figure(2)
subplot(2,3,1)
labelx = sprintf('fréquence (en Hz)');
labely = sprintf('magnitude');
label = sprintf('variation linéaire ; p = 10');

indice = floor(length(ff)/2);
hold off;
plot(0);
hold on;
grid on;
plot(ff(indice:indice+1000),mydsp(indice:indice+1000),'linewidth',2);
xlabel(labelx,'fontsize',15);
ylabel(labely,'fontsize',15);
title(label,'Fontsize',20);
hold off;
drawnow;
