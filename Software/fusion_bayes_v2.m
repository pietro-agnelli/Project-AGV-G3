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
falsePos = or(arucoData.id_marker > 8,abs(arucoData.x) > 800);
arucoData{falsePos,2:end} = NaN;
% scaling aruco measurements from mm to m
arucoData{:,3:6} = arucoData{:,3:6}./1000;
arucoData{:,'z'} = arucoData{:,'z'}-arucoData.z(1);

[~,framesindex] = unique(arucoData.frame);
arucoData = arucoData(framesindex,:);

[~,idx] = ismember(arucoData.frame,odomData.frame);
odomData = odomData(idx,:);
%%
figure
l = legend;
hold on
grid on
% axis equal
xlabel("x [m]",FontSize=14)
ylabel("z [m]",FontSize=14)
ylim([-2,2])
title('XZ trajectory')
%% Applying Bayes
UXAruco = Uaruco(1,1)/1000;
UZAruco = Uaruco(2,2)/1000;
fusedPos = zeros(height(odomData)/2,5);
lastFusedNode = 1;

dt = 1/12;
delta = 0.01;
eval = -1:delta:50;
%%
for n = 2:min(height(odomData),height(arucoData))/2%se aruco viene rilevato faccio sensor fusion
    % setting current uncertainties
    UXOdom = abs(predict(xMdl,[odomData.x(n)-odomData.x(lastFusedNode),odomData.z(n)-odomData.z(lastFusedNode),abs(mean(odomData.vx(1:n))),abs(mean(odomData.vz(1:n))),odomData.yaw(n)]));
    UZOdom = abs(predict(CrossZMdl,[odomData.x(n)-odomData.x(lastFusedNode),odomData.z(n)-odomData.z(lastFusedNode),abs(mean(odomData.vx(1:n))),abs(mean(odomData.vz(1:n))),odomData.yaw(n)]));
%         UXOdom = max(XUncertainty)
%         UZOdom = max(ZUncertainty)
    % offsetting aruco data assuming 6 uniformly spaced markers
    ds = abs(min(odomData.x)-max(odomData.x))/6;
    arucoData.x(n) = -arucoData.x(n) + ds * arucoData.id_marker(n) + arucoData.x(1);
    if arucoData.x(n) ~= 0 && ~isnan(arucoData.x(n)) && arucoData.z(n) ~= 0 && ~isnan(arucoData.z(n)) &&...
            arucoData.x(n-1) ~= 0 && ~isnan(arucoData.x(n-1)) &&arucoData.z(n-1) ~= 0 && ~isnan(arucoData.z(n-1))
        %% BAYES
        priorX = odomData.x(n-1) + odomData.vx(n-1)*dt;
        priorDistX = normpdf(eval, priorX, 0.7);
        priorDistZ = normpdf(eval, 0, std(odomData.z(1:n)));
        % aruco
        arucoDistX = normpdf(eval, arucoData.x(n), UXAruco);
        arucoDistZ = normpdf(eval, arucoData.z(n), UZAruco);
        % odometria
        odomDistX = normpdf(eval, odomData.x(n), UXOdom);
        odomDistZ = normpdf(eval, odomData.z(n), UZOdom);
        if n == 160
            figure
            plot(eval, priorDistX, 'c', eval, odomDistX, 'm', eval, arucoDistX, 'g')
            title("PDFs at step n=160")
            legend("x prior","odometry","ArUco")
            grid on
            figure
        end
        likelihoodProdX = priorDistX.*arucoDistX.*odomDistX;
        likelihoodProdZ = priorDistZ.*arucoDistZ.*odomDistZ;

        evidenceX = trapz(likelihoodProdX)*delta;
        evidenceZ = trapz(likelihoodProdZ)*delta;

        posteriorX = likelihoodProdX/evidenceX;
        posteriorZ = likelihoodProdZ/evidenceZ;
%         figure
%         plot(eval, priorDistX, eval, arucoDistX, eval, odomDistX)
        % expected values (credo corrispondano alla misura fusa... CREDO
        E_x = trapz(eval.*posteriorX)*delta;
        E_z = trapz(eval.*posteriorZ)*delta;

        % stdev (incertezza)
        UfusedX = sqrt(trapz((eval-E_x).^2.*posteriorX)*delta);
        UfusedZ = sqrt(trapz((eval-E_z).^2.*posteriorZ)*delta);

        fusedPos(n,:) = [E_x, E_z, UfusedX, UfusedZ, 1];
        lastFusedNode = n;
        % plotting connectors between fusion terms
%         plot([arucoData.x(n) fusedPos(n,1) odomData.x(n)],[arucoData.z(n) fusedPos(n,2) odomData.z(n)],'-k',DisplayName='Fusion terms connections')
%         l.AutoUpdate = 'off';
    else
        %se aruco non viene rilevato mi affido solo a odometria
        dx = (odomData.x(n)-odomData.x(n-1));
        dz = (odomData.z(n)-odomData.z(n-1));
        fusedPos(n,:) = [fusedPos(n-1,1:2)+[dx,dz], UXOdom, UZOdom, 0];
    end
end
%% Visualization
%l.AutoUpdate = 'on';
plot(odomData.x(1:end/2), odomData.z(1:end/2),'.r',DisplayName='Odometry')
plot(arucoData.x(1:end/2), arucoData.z(1:end/2), '.b',DisplayName='Aruco')
plot(fusedPos(:,1), fusedPos(:,2),'.-g',DisplayName='Bayes')

%% Uncertainty visualization
figure
subplot(2,1,1)
plot(fusedPos(:,1),fusedPos(:,3), '.-g',DisplayName='Clt')
title("X uncertainty")
xlabel("x [m]",FontSize=14)
ylabel("uncertainty [m]",FontSize=14)
ylim([0,0.15])
grid on

subplot(2,1,2)
plot(fusedPos(:,1),fusedPos(:,4), '.-g',DisplayName='Clt')
title("Z uncertainty")
xlabel("z [m]",FontSize=14)
ylabel("uncertainty [m]",FontSize=14)
ylim([0,0.15])
grid on
%%
[~,gof,~] = fit(odomData.frame,odomData.x,"Poly1");
gof.rmse
[~,gof,~] = fit(odomData.frame,odomData.z,"Poly1");
gof.rmse
[~,gof,~] = fit(odomData.frame(1:651),fusedPos(1:651,1),"Poly1");
gof.rmse
[~,gof,~] = fit(odomData.frame(1:651),fusedPos(1:651,2),"Poly1");
gof.rmse