function [zf_bayes,sigmazf_bayes] = bayes(x,z, sigma)
% BAYES FUSION
close all
%x = abs(filtered_aruco.pitch);
%z = (filtered_odom_pitch);
%sigma = sigmaz
%distances
a = 160;
b = 180;
pitch = a:(b-a)/342:b;
measure_bef = ones(1,343)*179;
Max = 0;
    for n = 2:height(x)
        m=abs(x(n,1)-z(n-1,1));
        if Max<m
            Max = m;
        end
    end

%devo calcolare la probabilità di una distanza fissata d data la misura x e
%z
for n = 1:height(sigma)
Pd_dato_x(n,:) = 1/(sqrt(2*pi)*sigma(n,1)).*exp((-1/2).*(pitch-x').^2./(sigma(n,1)).^2);
Pd_dato_z(n,:) = 1/(sqrt(2*pi*sigma(n,2).^2)).*exp((-1/2).*(pitch-z').^2./sigma(n,2).^2);
end
Patt_dato_prec = 1/(sqrt(2*pi*(2.89)^2)).*exp((-1/2).*(pitch-measure_bef').^2./((2.89)^2));
likelihood = Pd_dato_z.*Pd_dato_x.*Patt_dato_prec;
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
    zf_bayes = [zf_bayes pitch(index)];
end


%[zf_bayes, sigmazf_bayes] = bayes(abs(filtered_aruco.pitch) , filtered_odom_pitch , sigma_ar(3,3), sigma_odom(3,3));
end