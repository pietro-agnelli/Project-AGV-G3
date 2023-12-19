function [xf,sigmaf] = clt(x,sigma)
%CLT Applies central limit theorem to the input vector
%   x is a vector of n columns containing measurement column vectors, sigma
%   is a vector of length n containing measurement uncertainty, xf is the
%   fused data vector and sigmaf is its uncertainty
w = (sigma.^(-2))./sum(sigma.^(-2));
xf = x*w';
sigmaf = 1/sqrt(sum(sigma.^(-2)));
end

