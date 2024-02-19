close all
%% Load saved data
odomData = readtable("../Tests/MARKER_100/FRAME_0.05/POSE_DATA__2023_12_15_12_28_20_FRAME_0.01_PROVA_2.csv");
arucoData = readtable("../Tests/MARKER_100/FRAME_0.05/POSE_DATA___ARUCO_2023_12_15_12_28_20_FRAME_0.05_PROVA_2.csv");

load("../Tests/20240130/04_results/ExpXUncertainty.mat")
load("../Tests/20240130/04_results/ExpZUncertainty.mat")
load("../Tests/20240130/04_results/ExpThetaUncertainty.mat")
load("../Tests/20240130/04_results/CrossUncertaintyModels.mat")
load("../Tests/20231201/04_results/Uaruco.csv")
%% Data preprocessing
% removing false positives
falsePos = or(arucoData.id_marker > 8,abs(arucoData.x) > 500);
arucoData{falsePos,2:end} = NaN;
% scaling aruco measurements from mm to m
arucoData{:,3:6} = arucoData{:,3:6}./1000;
arucoData{:,'z'} = arucoData{:,'z'}-arucoData.z(1);

[~,framesindex] = unique(arucoData.frame);
arucoData = arucoData(framesindex,:);

[~,idx] = ismember(arucoData.frame,odomData.frame);
odomData = odomData(idx,:);
%% Model
%% State extrapolation
dt = 1/12; % timestep for 12fps
fusedPos = zeros(2,height(odomData)/2);
% identity matrix for convenience
I = eye(height(fusedPos));

% state vector initialization:
fusedPos(:,1) = [odomData.x(1);
                 odomData.z(1);];
% transition matrix
F = I;

% assuming velocity is our input
u = [odomData.vx';
     odomData.vz'];

G = [0 0;
     0  0];
%% Covariance extrapolation
P = I;
% process noise
sigma = 0.5;
Q = sigma^2*I;
%% Measurements equation
% Il vettore di stato è completamente osservabile
H = I;

figure
l = legend;
hold on
grid on
% axis equal
xlabel("x [m]",FontSize=14)
ylabel("z [m]",FontSize=14)
ylim([-2,2])
title('XZ trajectory')
%% Run
Raruco = diag([Uaruco(1,1)/1000, Uaruco(2,2)/1000]);
lastFusedNode = 1;
for n = 2:min(height(odomData),height(arucoData))/2

    Rodom = diag([predict(xMdl,[odomData.x(n),odomData.z(n),abs(mean(odomData.vx(1:n))),abs(mean(odomData.vz(1:n))),odomData.yaw(n)]),...
        predict(CrossZMdl,[odomData.x(n),odomData.z(n),abs(mean(odomData.vx(1:n))),abs(mean(odomData.vz(1:n))),odomData.yaw(n)])]).^2;
    
    ds = abs(min(odomData.x)-max(odomData.x))/6;
    arucoData.x(n) = -arucoData.x(n) + ds * arucoData.id_marker(n) + arucoData.x(1);
    if arucoData.x(n) ~= 0 && ~isnan(arucoData.x(n)) && arucoData.z(n) ~= 0 && ~isnan(arucoData.z(n)) &&...
            arucoData.x(n-1) ~= 0 && ~isnan(arucoData.x(n-1)) &&arucoData.z(n-1) ~= 0 && ~isnan(arucoData.z(n-1))

        [fusedPos(:,n), P] = prediction(fusedPos(:,n-1),P,Q,F);
        [fusedPos(:,n), P] = update(fusedPos(:,n-1),P,odomData{n,[2,4]}',Rodom,H);
        [fusedPos(:,n), P] = update(fusedPos(:,n-1),P,arucoData{n,[3,5]}',Raruco,H);
        lastFusedNode = n;
        % plotting connectors between fusion terms
        plot([arucoData.x(n) fusedPos(1,n) odomData.x(n)],[arucoData.z(n) fusedPos(2,n) odomData.z(n)],'-k',DisplayName='Fusion terms connections')
        l.AutoUpdate = 'off';
    else
%         [fusedPos(:,n), P] = prediction(fusedPos(:,n-1),P,Q,F);
%         [fusedPos(:,n), P] = update(fusedPos(:,n-1),P,odomData{n,[2,4]}',Rodom,H);
        dx = (odomData.x(n)-odomData.x(n-1));%*cos(odomData.yaw(n-1)*pi/180);
        dz = (odomData.z(n)-odomData.z(n-1));%*sin(odomData.yaw(n-1)*pi/180);
        fusedPos(:,n) = fusedPos(:,n-1)+[dx;dz];%, R(1,1), R(2,2), 0];
    end
end

%% Visualization
l.AutoUpdate = 'on';
plot(odomData.x(1:end/2), odomData.z(1:end/2),'.r',DisplayName='Odometry')
plot(arucoData.x(1:end/2), arucoData.z(1:end/2), '.b',DisplayName='Aruco')
plot(fusedPos(1,:), fusedPos(2,:),'.-g',DisplayName='Kf')
legend

%% Uncertainty
kfzstd = sqrt(sum((odomData.z(1)-fusedPos(2,:)).^2)/(length(fusedPos(1,:))-1))
Odomzstd = sqrt(sum((odomData.z(1)-odomData.z(1:end/2)).^2)/(length(odomData.x(1:end/2))-1))
%% Rmse
[~,gof,~] = fit(odomData.frame,odomData.x,"Poly1");
gof.rmse
[~,gof,~] = fit(odomData.frame,odomData.z,"Poly1");
gof.rmse
[~,gof,~] = fit(odomData.frame(1:length(fusedPos)),fusedPos(1,:)',"Poly1");
gof.rmse
[~,gof,~] = fit(odomData.frame(1:length(fusedPos)),fusedPos(2,:)',"Poly1");
gof.rmse
%% Functions

function [Xn, P] = prediction(Xn_1, P, Q, F)
    Xn = F*Xn_1;
    P = F*P*F' + Q;
end

function [Xn, P] = update(Xn_1, P, y, R, H)
%     K = P*H'/(H*P*H'+R);
%     P = (I-K*H)*P*(I-K*H)' + K*R*K';
%     Xn = Xn_1 + K*(y - H*Xn_1);
    Inn = y - H*Xn_1;
    S = H*P*H' + R;
    K = P*H'/S;

    Xn = Xn_1 + K*Inn;
    P = P - K*H*P;
end