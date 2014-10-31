close all;


fe=32000;   %% fr\'equence d'\'echantillonnage  (en Hz)
f0=440;     %% fr\'equence de la sinuso\"{\i}de (en Hz)
tsig=1280;  %% longueur du signal               (en nombre d'\'echantillons)
ordre=20;  %% ordre du mod\`ele AR
nb_test=10;
nb_point_vu = 10;
xx=cos(2*pi*f0/fe*[1:tsig]); 
figure(3)
plot(xx);

%[aa, sigma2, ref, ff, mydsp] = mylevinsondurbin(xx,ordre,fe); %%% calcul du mod\`ele AR
aa = levinson(xx,ordre);
signal = zeros(tsig,1);
signal(1)=xx(1);
test = zeros(tsig);

for i=2:tsig
   m = min(ordre,i-1);
   %tmp = ones(m+1,1);
   %tmp(1) = randn(1,1)*sigma2^(0.5);
   tmp = signal(i-1:-1:i-m);
   signal(i) = aa(2:m+1)*tmp; 
   test(i,:)=signal;
end

figure
plot(signal);