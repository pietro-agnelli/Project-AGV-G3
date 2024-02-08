% position x(n) = x(n-1) + v(n-1)*dt + a(n-1)*0.5*dt^2*cos(theta(n-1))
% where
% v(n) = v(n-1) + a*cos(theta(n-1))*dt
% uncertainty propagates as follow
% ux(n) = sqrt(ux(n-1)^2 + (uv(n-1)*cos(theta(n-1))*dt)^2 +
%       (ua*cos(theta(n-1))*dt)^2) + 
%       ((v(n-1)*dt + a(n-1)*0.5*dt^2)*sin(theta(n-1))*utheta(n-1))^2
% uv(n) = sqrt(uv(n-1)^2 + ua^2*cos(theta(n-1))^2*dt^2 +
%       utheta(n-1)^2*sin(theta(n-1))^2*dt^2)
% utheta(n) = sqrt(utheta(n-1)^2+uw^2*dt^2)

% at 12 fps
dt = 1/12;

% reading data from file
data = readtable('..\Tests\20240130\02_preprocessing\ortogonal\200\POSE_DATA__2023_03_02_14_08_12.csv');
theta = data.yaw.*pi./180;
v = data.vx;

% setting datasheet uncertainties
ua = 70e-3*9.81; % = 70 mg
uw = 1; % [°/s]

% initialize arrays
uv = zeros(1,height(data));
ux = zeros(1,height(data));
utheta = zeros(1,height(data));

uv(1) = 0;
ux(1) = 0.0059;
utheta(1) = 0.32*pi/180;

for n = 2:height(data)
    a = abs((v(n)-v(n-1))/dt);
    utheta(n) = sqrt(utheta(n-1)^2+uw^2*dt^2);
    uv(n) = sqrt(uv(n-1)^2 + ua^2*cos(theta(n-1))^2*dt^2 + ...
        utheta(n-1)^2*sin(theta(n-1))^2*dt^2);
    ux(n) = sqrt(ux(n-1)^2 + (uv(n-1)*dt)^2 + ...
        (ua*0.5*dt^2*cos(theta(n-1))*0.5*dt^2)^2 + ...
    ((a*0.5*dt^2)*sin(theta(n-1))*utheta(n-1))^2);
end

plot(ux)
hold on
% plot([0 n_frames],sqrt(sigma2x),'o')