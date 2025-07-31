function [zf,sigmaf] = bayes2(x,z,sigma)
% BAYES FUSION
close all
%x = abs(filtered_aruco.pitch);
%z = (filtered_odom_pitch);
%sigma = sigmaz
%distances
dx = 0.01;
prior = 0:dx:180
priorDist = normpdf(prior, 180, 0.01 );

%devo calcolare la probabilità di una distanza fissata d data la misura x e
%z
for n = 1:height(sigma)
Pd_dato_x = normpdf(prior, x(n), sigma(n,1))
Pd_dato_z = normpdf(prior, z(n), sigma(n,2))

likelihood = Pd_dato_z.*Pd_dato_x;
vec =0;
for i = 1:height(likelihood)
    vec = sum(likelihood(i, :));
    bayes(i,:) = likelihood(i,:)./(vec*(180/342));
end

zf_bayes = [];
sigmazf_bayes = [];
for i = 1:height(bayes)
    raw = (bayes(i,:));
    [val, index] = max(raw);
    sigmazf_bayes = [sigmazf_bayes val];
    zf_bayes = [zf_bayes prior(index)];
end
end