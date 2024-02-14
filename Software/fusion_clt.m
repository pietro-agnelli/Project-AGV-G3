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
falsePos = arucoData.id_marker > 8;
arucoData{falsePos,2:end} = NaN;
% scaling aruco measurements from mm to m
arucoData{:,3:6} = arucoData{:,3:6}./1000;
arucoData{:,'z'} = arucoData{:,'z'}-arucoData.z(1);

[~,framesindex] = unique(arucoData.frame);
arucoData = arucoData(framesindex,:);

[~,idx] = ismember(arucoData.frame,odomData.frame);
odomData = odomData(idx,:);
%% Applying CLT
UXAruco = Uaruco(1,1)/1000;  
UZAruco = Uaruco(2,2)/1000;
fusedPos = zeros(height(odomData)/2,5);
lastFusedNode = 1;
for n = 1:min(height(odomData),height(arucoData))/2
    % setting current uncertainties
    UXOdom = abs(predict(xMdl,[odomData.x(n)-odomData.x(lastFusedNode),odomData.z(n)-odomData.z(lastFusedNode),abs(mean(odomData.vx(1:n))),abs(mean(odomData.vz(1:n))),odomData.yaw(n)]));
    UZOdom = abs(predict(CrossZMdl,[odomData.x(n)-odomData.x(lastFusedNode),odomData.z(n)-odomData.z(lastFusedNode),abs(mean(odomData.vx(1:n))),abs(mean(odomData.vz(1:n))),odomData.yaw(n)]));
%     UXOdom = max(XUncertainty)
%     UZOdom = max(ZUncertainty)
    % offsetting aruco data assuming 6 uniformly spaced markers
    ds = abs(min(odomData.x)-max(odomData.x))/6;
    arucoData.x(n) = -arucoData.x(n) + ds * arucoData.id_marker(n) + arucoData.x(1);
    if and(arucoData.y(n) ~= 0, ~isnan(arucoData.y(n)))
        % calculate weights
        arucoXW = (UXAruco^(-2))/(UXAruco^(-2)+UXOdom^(-2));
        odomXW = (UXOdom^(-2))/(UXAruco^(-2)+UXOdom^(-2));
        arucoZW = (UZAruco^(-2))/(UZAruco^(-2)+UZOdom^(-2));
        odomZW = (UZOdom^(-2))/(UZAruco^(-2)+UZOdom^(-2));

        fusedPos(n,:) = [arucoData.x(n)*arucoXW + odomData.x(n)*odomXW,...
            arucoData.z(n)*arucoZW + odomData.z(n)*odomZW,...
            1/sqrt(arucoXW^(-2)+odomXW^(-2)),...
            1/sqrt(arucoZW^(-2)+odomZW^(-2)),...
            1];
        lastFusedNode = n;
    else
        dx = (odomData.x(n)-odomData.x(n-1));%*cos(odomData.yaw(n-1)*pi/180);
        dz = (odomData.z(n)-odomData.z(n-1));%*sin(odomData.yaw(n-1)*pi/180);
        fusedPos(n,:) = [fusedPos(n-1,1:2)+[dx,dz], UXOdom, UZOdom, 0];
    end
end

%% Visualization
figure
hold on
plot(odomData.x(1:end/2), odomData.z(1:end/2),'.r',DisplayName='Odometry')
plot(arucoData.x(1:end/2), arucoData.z(1:end/2), '.b',DisplayName='Aruco')
plot(fusedPos(:,1), fusedPos(:,2),'.-g',DisplayName='Clt')
axis equal
title('XZ trajectory')
legend
grid on

%% Cov ellipses
figure
hold on
grid on
axis equal
title('Fused trajectory')
plot(fusedPos(139:349,1), fusedPos(139:349,2),'.-b',DisplayName='Clt')

for n = 139:10:187
    error_ellipse(diag([fusedPos(n,3) fusedPos(n,4)]),[fusedPos(n,1),fusedPos(n,2)],'style','--g')
end
for n = 188:10:259
    error_ellipse(diag([fusedPos(n,3) fusedPos(n,4)]),[fusedPos(n,1),fusedPos(n,2)],'style','--r')
end
for n = 260:10:301
    error_ellipse(diag([fusedPos(n,3) fusedPos(n,4)]),[fusedPos(n,1),fusedPos(n,2)],'style','--g')
end
for n = 302:10:349
    error_ellipse(diag([fusedPos(n,3) fusedPos(n,4)]),[fusedPos(n,1),fusedPos(n,2)],'style','--r')
end
