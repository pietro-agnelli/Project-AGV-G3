%% Load saved data
odomData = readtable("../Tests/MARKER_100/FRAME_0.05/POSE_DATA__2023_12_15_12_28_20_FRAME_0.01_PROVA_2.csv");
arucoData = readtable("../Tests/MARKER_100/FRAME_0.05/POSE_DATA___ARUCO_2023_12_15_12_28_20_FRAME_0.05_PROVA_2.csv");

load("../Tests/20240130/04_results/ExpXUncertainty.mat")
load("../Tests/20240130/04_results/ExpZUncertainty.mat")
load("../Tests/20240130/04_results/ExpThetaUncertainty.mat")
load("../Tests/20240130/04_results/UncertaintyModels.mat")
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
fusedPos = zeros(height(odomData),5);

for n = 1:min(height(odomData),height(arucoData))
    % setting current uncertainties
    UXOdom = abs(predict(xMdl,[odomData.x(n),odomData.z(n),odomData.vx(n),odomData.vz(n),odomData.yaw(n)]));
    UZOdom = abs(predict(zMdl,[odomData.x(n),odomData.z(n),odomData.vx(n),odomData.vz(n),odomData.yaw(n)]));
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
    else
        dx = odomData.x(n)-odomData.x(n-1);
        dz = odomData.z(n)-odomData.z(n-1);
        fusedPos(n,:) = [fusedPos(n-1,1:2)+[dx,dz], UXOdom, UZOdom, 0];
    end
end

%% Visualization
figure
hold on
plot(odomData.x, odomData.z,'.r',DisplayName='Odometry')
plot(arucoData.x, arucoData.z, '.b',DisplayName='Aruco')
plot(fusedPos(:,1), fusedPos(:,2),'-g',DisplayName='Clt')
axis equal
legend
grid on

%% Cov ellipses

figure
hold on
for n = 1:50:length(fusedPos)/2
    error_ellipse(diag([fusedPos(n,3) fusedPos(n,4)]),[fusedPos(n,1),fusedPos(n,2)])
    plot(fusedPos(n,1),fusedPos(n,2),'.',Displayname=string(n))
end
axis equal
legend
