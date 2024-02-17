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
axis equal
xlabel("x [m]")
ylabel("z [m]")
title('XZ trajectory')
%% Applying Bayes
UXAruco = Uaruco(1,1)/1000;  
UZAruco = Uaruco(2,2)/1000;
fusedPos = zeros(height(odomData)/2,5);
lastFusedNode = 1;

dt = 1/12;
%%
for n = 2:min(height(odomData),height(arucoData))/2%se aruco viene rilevato faccio sensor fusion
    % setting current uncertainties
    UXOdom = abs(predict(xMdl,[odomData.x(n)-odomData.x(lastFusedNode),odomData.z(n)-odomData.z(lastFusedNode),abs(mean(odomData.vx(1:n))),abs(mean(odomData.vz(1:n))),odomData.yaw(n)]));
    UZOdom = abs(predict(CrossZMdl,[odomData.x(n)-odomData.x(lastFusedNode),odomData.z(n)-odomData.z(lastFusedNode),abs(mean(odomData.vx(1:n))),abs(mean(odomData.vz(1:n))),odomData.yaw(n)]));
    %     UXOdom = max(XUncertainty)
    %     UZOdom = max(ZUncertainty)
    % offsetting aruco data assuming 6 uniformly spaced markers
    ds = abs(min(odomData.x)-max(odomData.x))/6;
    arucoData.x(n) = -arucoData.x(n) + ds * arucoData.id_marker(n) + arucoData.x(1);
    if and(arucoData.z(n)~= 0, ~isnan(arucoData.z(n))) & and(arucoData.x(n)~= 0, ~isnan(arucoData.x(n))) & and(arucoData.y(n)~= 0, ~isnan(arucoData.y(n)))

        distanceX = floor(arucoData.x(n)):UXAruco:floor(arucoData.x(n))+2;
        distanceZ = -0.05:0.1/103:0.05;

        % calcolo le probabilità condizionate
        %         Pd_dato_x_aruco = 1/(sqrt(2*pi)*UXAruco)*exp((-1/2)*(distanceX-arucoData.x(n)).^2./UXAruco^2);
        %         Pd_dato_x_odom = 1/(sqrt(2*pi)*UXOdom)*exp((-1/2)*(distanceX-odomData.x(n)).^2./UXOdom^2);
        %         Pd_dato_z_aruco = 1/(sqrt(2*pi)*UZAruco)*exp((-1/2)*((distanceZ)-(arucoData.z(n))).^2./UZAruco^2);
        %         Pd_dato_z_odom = 1/(sqrt(2*pi)*UZOdom)*exp((-1/2)*((distanceZ)-(odomData.z(n))).^2./UZOdom^2);
        prior_distributionX = normpdf(distanceX , mean(distanceX), 0.05);
        prior_distributionZ = normpdf(distanceZ,0, 0.02);
        p_odomX = normpdf(distanceX,mean(odomData.x(:)), UXOdom);
        p_arucoX = normpdf(distanceX,mean(distanceX) ,UXAruco);
        p_odomZ = normpdf(distanceZ, mean(odomData.z(:)) , UZOdom);
        p_arucoZ = normpdf(distanceZ,0,UZAruco);

% 
%         plot(prior_distributionX)
%         hold on
%         plot(p_odomX)
%         hold on
%         plot(p_arucoX)
%         pause
        likelihoodX =p_odomX.*prior_distributionX;
        likelihoodZ =p_odomZ.*prior_distributionZ;


        evidenceX =trapz(likelihoodX)*(distanceX(2)-distanceX(1))
        evidenceZ = (trapz(likelihoodZ)*(distanceZ(2)-distanceZ(1)));
        posterior_probabilityZ = likelihoodZ./evidenceZ;
        posterior_probabilityX = likelihoodX./evidenceX;

        [UX, fusedX] = max(posterior_probabilityX)
        [UZ, fusedZ] = max(posterior_probabilityX)
        fusedPos(n,:) = [distanceX(fusedX),...
            distanceZ(fusedZ),...
            UX,...
            UZ,...
            1];
        lastFusedNode = n;
        
%         plot(posterior_probabilityX)
%         pause



        %         Patt_prec_X = 1/(sqrt(2*pi)*U99X)*exp((-1/2)*(distanceX-fusedPos(n-1,1)).^2./U99X^2);
        %         Patt_prec_Z = 1/(sqrt(2*pi)*U99Z)*exp((-1/2)*(abs(distanceZ)-abs(fusedPos(n-1,2))).^2./U99Z^2);
        %         likelihoodX = Pd_dato_x_aruco.* Pd_dato_x_odom.*Patt_prec_X;
        %         likelihoodZ = Pd_dato_z_aruco.*Pd_dato_z_odom.*Patt_prec_Z;
        %         %
        %         %         figure
        %         %         plot(distanceX,Pd_dato_x_aruco)
        %         %         hold on
        %         %         plot(distanceX,Pd_dato_x_odom)
        %         %preparo le likelihood function per fare la fusiùone
        %
        %         sum(likelihoodX)
        %         sum(likelihoodZ)
        %         %applico bayes dove sono stati visti gli aruco
        %         if 0<sum(likelihoodX)<1 & sum(likelihoodZ)~= 0
        %             bayesX = likelihoodX./(sum(likelihoodX)*UXAruco);
        %             dz = (odomData.z(n)-odomData.z(n-1));%*sin(odomData.yaw(n-1)*pi/180)
        %             [UX, fusedX] = max(bayesX)
        %
        %             fusedPos(n,:) = [distanceX(fusedX),...
        %                 fusedPos(n-1,2)+dz,...
        %                 UX,...
        %                 UZOdom,...
        %                 1];
        %             lastFusedNode = n;
        %
        %         elseif (0<sum(likelihoodX)<1) & (0<sum(likelihoodZ)<1)
        %             bayesX = likelihoodX./(sum(likelihoodX)*UXAruco);
        %             bayesZ = likelihoodZ./(sum(likelihoodZ)*UXAruco);
        %             [UX, fusedX] = max(bayesX)
        %             [UZ, fusedZ] = max(bayesZ)
        %              fusedPos(n,:) = [distanceX(fusedX),...
        %                 distanceZ(fusedZ),...
        %                 UX,...
        %                 UZ,...
        %                 1];
        %             lastFusedNode = n;
        %         elseif 0<sum(likelihoodZ)<1 & sum(likelihoodX)~= 0
        %             bayesZ = likelihoodZ./(sum(likelihoodZ)*UXAruco);
        %             dx = (odomData.x(n)-odomData.x(n-1));%*cos(odomData.yaw(n-1)*pi/180);
        %             [UZ, fusedZ] = max(bayesZ)
        %
        %             fusedPos(n,:) = [fusedPos(n-1,1)+dx,...
        %                 distanceZ(fusedZ),...
        %                 UXOdom,...
        %                 UZ,...
        %                 1];
        %             lastFusedNode = n;
        %         elseif sum(likelihoodZ)~= 0 & sum(likelihoodX)~= 0
        %             dx = (odomData.x(n)-odomData.x(n-1));%*cos(odomData.yaw(n-1)*pi/180);
        %             dz = (odomData.z(n)-odomData.z(n-1));%*sin(odomData.yaw(n-1)*pi/180);
        %             fusedPos(n,:) = [fusedPos(n-1,1:2)+[dx,dz], UXOdom, UZOdom, 0];
        %         end
    else
        % plotting connectors between fusion terms
        %plot([arucoData.x(n) fusedPos(n,1) odomData.x(n)],[arucoData.z(n) fusedPos(n,2) odomData.z(n)],'-k',DisplayName='Fusion terms connections')
        %l.AutoUpdate = 'off';

        %se aruco non viene rilevato mi affido solo a odometria
        dx = (odomData.x(n)-odomData.x(n-1));%*cos(odomData.yaw(n-1)*pi/180);
        dz = (odomData.z(n)-odomData.z(n-1));%*sin(odomData.yaw(n-1)*pi/180);
        fusedPos(n,:) = [fusedPos(n-1,1:2)+[dx,dz], UXOdom, UZOdom, 0];
    end
end
%% Visualization
%l.AutoUpdate = 'on';
plot(odomData.x(1:end/2), odomData.z(1:end/2),'.r',DisplayName='Odometry')
plot(arucoData.x(1:end/2), arucoData.z(1:end/2), '.b',DisplayName='Aruco')
plot(fusedPos(:,1), fusedPos(:,2),'.-g',DisplayName='Clt')

%% Uncertainty visualization
figure
subplot(2,1,1)
plot(fusedPos(:,1),fusedPos(:,3), '.-g',DisplayName='Clt')
title("X uncertainty")
xlabel("x [m]")
ylabel("uncertainty [m]")
grid on

subplot(2,1,2)
plot(fusedPos(:,1),fusedPos(:,4), '.-g',DisplayName='Clt')
title("Z uncertainty")
xlabel("z [m]")
ylabel("uncertainty [m]")
grid on
% %% Cov ellipses
% figure
% hold on
% grid on
% axis equal
% l = legend;
% title('Fused trajectory')
% plot(fusedPos(188:349,1), fusedPos(188:349,2),'.-g',DisplayName='Clt')
% plot(arucoData.x(188:349),arucoData.z(188:349),'.b',DisplayName='Aruco')
% plot(odomData.x(188:349),odomData.z(188:349),'.r',DisplayName='Odometry')
% l.AutoUpdate = 'off';
% % for n = 139:10:187
% %     error_ellipse(diag([fusedPos(n,3) fusedPos(n,4)]),[fusedPos(n,1),fusedPos(n,2)],0.95,'style','--g')
% % end
% for n = 188:10:262
%     error_ellipse(diag([fusedPos(n,3) fusedPos(n,4)]),[fusedPos(n,1),fusedPos(n,2)],0.95,'style','-.m')
% end
% for n = 263:10:289
%     error_ellipse(diag([fusedPos(n,3) fusedPos(n,4)]),[fusedPos(n,1),fusedPos(n,2)],0.95,'style','-.k')
% end
% for n = 290:10:349
%     error_ellipse(diag([fusedPos(n,3) fusedPos(n,4)]),[fusedPos(n,1),fusedPos(n,2)],0.95,'style','-.m')
% end
% 
% xlabel("x [m]")
% ylabel("z [m]")
%%
[U, idx]= max(fusedPos(:,3))