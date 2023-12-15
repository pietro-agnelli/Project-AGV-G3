function [xf,sigmaf] = clt(x,sigma)
%FUNCTION NAME:
%   clt
%
% DESCRIPTION:
%   Applies central limit theorem
%
% INPUT:
%   x - (double) vector of n columns containing measurement column vectors
%   sigma - (double) vector of length n containing measurement uncertainty
%
% OUTPUT:
%   xf - (double) vector of fused measurement
%   sigmaf - (double) fused measurement uncertainty
%
% ASSUMPTIONS AND LIMITATIONS:
%   None
%
% REVISION HISTORY:
%   15/12/2023 - mmyers
%       * Initial implementation
%  
w = (sigma.^(-2))./sum(sigma.^(-2));
xf = x*w';
sigmaf = 1/sqrt(sum(sigma.^(-2)));
end

