function [sigmax] = uncertainty_prop_v2(sigma_w, sigma_a,nofmeasures, dt, w, acc)
%UNCERTAINTY_PROP Summary of this function goes here
%   Detailed explanation goes here

%sigma2_0 = [sigma2_x0 sigma2_v0 sigma2_a0; sigma2_the0 sigma2_w0 sigma2_alpha0 ]
%matrice contenente tutte le varianze del sensore 

%nofmeasures: numero delle misure

%dt: framerate [s]

%ipotizzo distribuzione gaussiana, genero valori casuali distribuiti
%normalmente (a, w); legge di moto genero posizione vel ecc e theta
for i = 2: (nofmeasures)
    theta = [theta theta(i-1)+ w(i-1)*dt];
    vel = [vel vel(i-1)+acc(i-1)*dt];

end

%vettori delle varianze delle grandezze lineari e angolari, ponendo
%la sigma2 attuale come quella del sensore (sigma0)
sigmax  = [];
sigma2x = [0 0 0];
sigma2v = [0 0 0];
sigma2a =(sigma_a)^2;
sigma2theta =[ 0 0 0];
sigma2_w  = (sigma_w)^2;
for n = 4:(nofmeasures)
    sigma2v = [sigma2v sigma2v(n-1) + sqrt(sigma2a)];
    sigma2theta = [sigma2theta sigma2theta(n-1) + sqrt(sigma2_w)];
end
for n = 4 :1: (nofmeasures)
    sigma2x(n) =sigma2x(n-1) + ...
        (dt^2)*cos(theta(n-2)+w(n-2)*dt)^2*(sigma2v(n-3)+sqrt(sigma2a)*dt^2)+...
        (9/4)*(dt^4)*cos(theta(n-2)+w(n-2)*dt)^2*sigma2a + ...
        (vel(n-2)*dt +3/2*acc(n-2)*dt^2)^2*sin(theta(n-2)+w(n-2)*dt)^2*(sigma2theta(n-3)+sigma_w*dt^2)+ ...
        dt^2*(vel(n-2)*dt + 3/2*acc(n-2)*dt^2)^2*sin(theta(n-2)+w(n-2)*dt)^2*sigma_w^2;
end
end