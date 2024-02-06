function [sigmadeltax] = sigmadeltax(sigmax,sigma2theta, theta)
%Dalla formula della Propagazione dell'errore
% x(i)= x(i-1) +dx*cos(theta(i))
% theta(i) = theta(i-1)+ dtheta
% 
% nota sigmax e sigmatheta per uno spostamento dx, propago:
% 
% sigmax(i)^2 = sigmax(i-1)^2 + sigmax^2 sen(theta)^2*(sigmatheta(i-1)^2 + sigmatheta^2)

%sigmax parameter : [sigma50 sigma100 sigma150 sigma200];
%sigmatheta parameter: [sigma0 sigma30 sigma45 sigma60 sigma90]
%theta: current angle
%Sigma2deltax = incognita;

%first of we need to propagate the sigmatheta as
%sigma2theta = sigma2theta(i) - sigma2theta(i-1)
%where
%sigmtheta(i) =[sigma30 sigma45 sigma60 sigma90]
%sigmatheta(i-1) = [sigma0 sigma30 sigma45 sigma60]
for i = 2:length(sigmax)
sigma2deltax = (- sigmax(i)^2- sigmax(i-1)^2*sigma2theta*sin(theta)^2 + sigma2x(n))./(cos(theta)^2);
end
sigmadeltax = sqrt(sigma2deltax)