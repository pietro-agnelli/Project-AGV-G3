function [xf,sigmaf] = clt(x,sigma)
%CLT applies the central limit theorem to the input vector
%   
w = (sigma.^(-2))./sum(sigma.^(-2));
xf = x(1)*w(1)+x(2).*w(2);
sigmaf = 1/sqrt(sum(sigma.^(-2)));
end

