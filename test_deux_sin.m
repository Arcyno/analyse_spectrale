%% test de reconnaissance de  deux sinusoides pure.


fe=32000;   %% fr\'equence d'\'echantillonnage  (en Hz)
f0=440;     %% fr\'equence de la sinuso\"{\i}de (en Hz)
tsig=1280;  %% longueur du signal               (en nombre d'\'echantillons)
ordre=300;  %% ordre du mod\`ele AR
nb_test=100;
nb_point_vu = 1000;
xx1=sin(2*pi*f0/fe*[1:tsig]);                        %%% construction du signal


for i=1:nb_test
    f2=f0+i;
    xx2=sin(2*pi*f2/fe*[1:tsig]);                        %%% construction du signal
    xx = xx1 + xx2;
    
    [aa, sigma2, ref, ff, mydsp] = mylevinsondurbin(xx,ordre,fe); %%% calcul du mod\`ele AR
    L = findpeaks(mydsp(floor(size(mydsp,2)/2):floor(size(mydsp,2)/2)+nb_point_vu)); %%délimitation des maximas
    
    y=-1:0.05:6;

    figure(2)
    hold off;
    plot(f2,y);
    hold on;
    plot(ff(floor(size(ff,2)/2):floor(size(ff,2)/2)+nb_point_vu),L);
    
end

