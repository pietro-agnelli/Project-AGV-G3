function [xf, sigmaf] = bayes(x,z,sigmax, sigmaz)
%x: vettore misure primo sensore
%z: vettore misure del secondo vettore
%sigmax: incertezza primo sensore (numero reale)
%sigmaz: incertezza secondo sensore (numero reale)


%faccio la media dei valori misurati dai due sensori
xmean = sigmax.*((sigmax+sigmaz).^(-1)).*z + sigmaz.*((sigmax+sigmaz).^(-1)).*x; 

%definisco la sigma data dai due sensori
sigma2 = (1/sigmax.^2 + 1/sigmaz.^2).^(-1);

%devo calcolare la probabilità di una distanza fissata d data la misura x e
%z
d = 0:2000;%[mm]
Pd_dato_x = (1/sqrt(2*pi*sigma2))*exp(-1/2*(x-))



end