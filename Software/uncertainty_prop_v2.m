function [sigmax] = uncertainty_prop_v2(sigma2_0,nofmeasures, dt, theta, w, alpha, vel, acc)
%UNCERTAINTY_PROP Summary of this function goes here
%   Detailed explanation goes here

%sigma2_0 = [sigma2_x0 sigma2_v0 sigma2_a0; sigma2_the0 sigma2_w0 sigma2_alpha0 ]
%matrice contenente tutte le varianze del sensore 

%nofmeasures: numero delle misure

%dt: framerate [s]

%vettori delle varianze delle grandezze lineari e angolari, ponendo
%la sigma2 attuale come quella del sensore (sigma0)
sigma2x = [ 0 0 sigma2_0(1,1)];
sigma2v = [0 0 sigma2_0(1,2) ];
sigma2a =sigma2_0(1,3);
sigma2theta =[ 0 0 sigma2_0(2,1)];
sigma2_w =sigma2_0(2,2);
sigma2alpha =[ 0 0 sigma2_0(2,3)];
for n = 4:nofmeasures
    sigma2v = [sigma2v sigma2v(n-1) + sqrt(sigma_a)];
    sigma2theta = [sigma2theta sigma2theta(n-1) + sqrt(sigma_w)];
    sigmax = [sigmax sqrt(sigma2x(n-1) + dt^2*cos(theta(n-2)+w(n-2)*dt)^2*(sigma2v(n-3)+sqrt(sigma2a)*dt^2)+9/4*dt^4*cos(theta(n-2)+w(n-2)*dt)^2*sigma2a + (vel(n-2)*dt + 3/2*acc(n-2)*dt^2)^2*sin(theta(n-2)+w(n-2)*dt)^2*(sigma2theta(n-3)+sigma_w*dt^2)+dt^2*(vel(n-2)*dt + 3/2*acc(n-2)*dt^2)^2*sin(theta(n-2)+w(n-2)*dt)^2)];
end
end