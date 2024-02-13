%% Load saved data
ds = readtable("../Tests/MARKER_100/FRAME_0.05/POSE_DATA__2023_12_15_12_28_20_FRAME_0.01_PROVA_2.csv");
z = table2array(ds);

load("../Tests/20240130/04_results/ExpXUncertainty.mat")
load("../Tests/20240130/04_results/ExpZUncertainty.mat")
load("../Tests/20240130/04_results/ExpThetaUncertainty.mat")
load("../Tests/20240130/04_results/UncertaintyModels.mat")
%% Visualization
% figure
% plot(ds.x,ds.z,'o')
% legend('measured')
% title('Traiettoria XZ')
% xlabel('X [m]')
% ylabel('Z [m]')
% axis equal
%% State extrapolation

dt = 1/12; % timestep for 12fps

% state vector initialization:
% our state vector is x = [x; z; theta]
% our state trasition matrix is
% F = [1 0 sin(theta);
%      0 1 cos(theta);
%      0 0 1];
nofstates = 3;

% Condizioni iniziali
x = zeros(nofstates,length(ds.x));
k = zeros(length(ds.x),1);

x(:,1) = [ds.x(1);
          ds.z(1);
          ds.yaw(1)];

% identity matrix vor convenience

I = eye(height(x));

% assuming velocity is our input

u = [ds.vx';
     ds.vz'];

G = [0 0;
     0  0;
     0  0 ];

% the system is x(n) = F*x(n-1) + G*u

%% Covariance extrapolation

P = I;

% process noise
sigma = 0.00009;
% Q = sigma*(G*G');
% Q = cov([ds.x,ds.z,ds.yaw]);
Q = sigma^2*I;

%% Measurements equation
% Il vettore di stato è completamente osservabile
H = I;
% uncomment to use fixed disturbance
R = diag([min(XUncertainty),...
        min(ZUncertainty),...
        min(UTheta)]).^2;
F = I;
for n=2:height(z)

%     F = [1 0 sin(ds.yaw(n-1));
%          0 1 cos(ds.yaw(n-1));
%          0 0 1];

%     R = diag([predict(xMdl,[ds.x(n-1),ds.z(n-1),ds.vx(n-1),ds.vz(n-1),ds.yaw(n-1)]),...
%         predict(zMdl,[ds.x(n-1),ds.z(n-1),ds.vx(n-1),ds.vz(n-1),ds.yaw(n-1)]),...
%         predict(thetaMdl,[ds.x(n-1),ds.z(n-1),ds.vx(n-1),ds.vz(n-1),ds.yaw(n-1)])]).^2;
    
    % Predict
    x(:,n) = F*x(:,n-1) + G*u(:,n-1);
    P = F*P*F' + Q;
    
    % Update
    K = P*H'/(H*P*H'+R);
    P = (I-K*H)*P*(I-K*H)' + K*R*K';
    x(:,n) = x(:,n-1) + K*(z(n,[2 3 9])' - H*x(:,n-1));
    k(n) = K(1,1);
end

figure
hold on
plot(ds.x,ds.z(1)*ones(length(ds.x),1),'--k')
plot(x(1,:),x(2,:),'r')
plot(ds.x,ds.z,'.b')
legend('Theorical','Kalman','Measurements')
xlabel('X [m]')
ylabel('Y [m]')
axis equal
title('Traiettoria XZ')
grid on

figure
hold on
plot(k);
title("Kalman gain")

%% Evaluation
measSSE = sum((ds.z(1)*ones(length(ds.x),1)-ds.z).^2)
kalmanSSE = sum((ds.z(1)*ones(length(ds.x),1)-x(2,:)').^2)
