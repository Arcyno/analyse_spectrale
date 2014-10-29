%% test de reconnaissance d'une sinusoide a freq variable.
%%%%% rmq : ordre bas -> un pic, ordre élevé -> une bande
%choisir entre variation exp et linéraire

close all

fe=32000;   %% fr\'equence d'\'echantillonnage  (en Hz)
tsig=12800;  %% longueur du signal               (en nombre d'\'echantillons)
fmin=400;     %% fr\'equence de la sinuso\"{\i}de (en Hz)
fmax=500;     %% fr\'equence de la sinuso\"{\i}de (en Hz)
ordre=500;  %% ordre du mod\`ele AR

%%intiialisation
f=fmin;
xx = [1:tsig];


%% variation linéaire
df = (fmax-fmin)/tsig;
for k=1:tsig
f=f+df;
xx(k)=sin(2*pi*f/fe*k);                        %%% construction du signal
end

% %%% variation exp
% df=log(fmax/fmin)/tsig;
% for k=1:tsig
% f=exp(log(fmin)+df*k)
% xx(k)=sin(2*pi*f/fe*k);                        %%% construction du signal
% end

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
