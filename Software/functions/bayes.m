function [xf, sigmaf] = bayes(x,z,sigmax, sigmaz)
%x: vettore misure primo sensore
%z: vettore misure del secondo vettore
%sigmax: incertezza primo sensore (numero reale)
%sigmaz: incertezza secondo sensore (numero reale)
%xf = (sigmax.^2/(sigmax.^2+sigmaz.^2)).*z' + (sigmaz.^2/(sigmax.^2+sigmaz.^2)).*x';
xf = sigmax.*((sigmax+sigmaz).^(-1)).*z + sigmaz.*((sigmax+sigmaz).^(-1)).*x;
sigmaf = sqrt((1/sigmax.^2 + 1/sigmaz.^2).^(-1));
end