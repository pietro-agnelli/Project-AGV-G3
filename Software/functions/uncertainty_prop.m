function [sigma] = uncertainty_prop(sigma0,nofmeasures)
%UNCERTAINTY_PROP Summary of this function goes here
%   Detailed explanation goes here
sigma = [];
sigma(1) = sigma0;
sigma(2) = 2*sigma(1);
for n = 3:nofmeasures
    sigma = [sigma sqrt(2*sigma(n-1)^2-sigma(n-2)^2)];
end
end

