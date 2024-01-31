clear
close all

%% IMPORT DATA

PATH = "../Tests/20231201/02_preprocessing";

% Translation along x axis 
DATASET_ZX_PARALLEL_1 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_10_05.csv");
DATASET_ZX_PARALLEL_2 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_14_05.csv");
zx_dataset = DATASET_ZX_PARALLEL_2;%[DATASET_ZX_PARALLEL_1; DATASET_ZX_PARALLEL_2];
save("../Tests/20231201/03_analysis/zx_dataset.mat","zx_dataset")

% Translation along z axis
DATASET_XZ_ORTHO_1 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_06_54.csv");
DATASET_XZ_ORTHO_2 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_09_02.csv");
xz_dataset = [DATASET_XZ_ORTHO_1; DATASET_XZ_ORTHO_2];
save("../Tests/20231201/03_analysis/xz_dataset.mat","xz_dataset")

% Translation 30 deg from z axis
DATASET_THETA_30_1 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_03_14.csv");
DATASET_THETA_30_2 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_05_08.csv");
theta_30_dataset = [DATASET_THETA_30_1;DATASET_THETA_30_2];
save("../Tests/20231201/03_analysis/theta_30_dataset.mat","theta_30_dataset")

% Translation 45 deg from z axis
DATASET_THETA_45_1 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_10_59_33.csv");
DATASET_THETA_45_2 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_01_45.csv");
theta_45_dataset = [DATASET_THETA_45_1;DATASET_THETA_45_2];
save("../Tests/20231201/03_analysis/theta_45_dataset.mat","theta_45_dataset")

% Translation 60 deg from z axis
DATASET_THETA_60_1 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_10_55_40.csv");
DATASET_THETA_60_2 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_10_57_50.csv");
theta_60_dataset =[DATASET_THETA_60_1;DATASET_THETA_60_2];
save("../Tests/20231201/03_analysis/theta_60_dataset.mat","theta_60_dataset")

%% LINEAR REGRESSION

% Setting common options for all regressions
opt = fitoptions('Method', 'LinearLeastSquares');

% Plot z as a function of x (translation along x axis)
% figure("Name", "XZ")
figure("Name", "Linear Regression")
[zx_model, gof_zx, out_zx] = fit(zx_dataset.x,zx_dataset.z,'Poly1',opt);
subplot(2,3,1,'replace')
plot(zx_model,zx_dataset.x,zx_dataset.z)
hold on
% plot(zx_dataset.x,zx_dataset.z,'*b',MarkerSize=4,DisplayName='Data points')
% hold on
% axis equal
grid on
xlabel("x[mm]")
ylabel("z[mm]")
title("Translation along X")
%% 
% Plot x as a function of z (translation along z axis)
% figure("Name","ZX")
subplot(2,3,2,"replace")
[xz_model, gof_xz, out_xz] = fit(xz_dataset.z,xz_dataset.x,'Poly1',opt);
plot(xz_model,xz_dataset.z,xz_dataset.x)
hold on
% plot(xz_dataset.z,xz_dataset.x,'*b',MarkerSize=4,DisplayName='Data points')
title("Translation along Z")
% axis equal
grid on
xlabel("z[mm]")
ylabel("x[mm]")
%%
% Plot pitch as a function of z (moving along z axis) for different theta
% figure("Name","THETA_0")
subplot(2,3,3,"replace")
[theta_0_model, gof_0, out_0] = fit(xz_dataset.z, abs(xz_dataset.pitch),'Poly1',opt);
plot(theta_0_model,xz_dataset.z,abs(xz_dataset.pitch))
hold on
% plot(xz_dataset.z,abs(xz_dataset.pitch),'*b',MarkerSize=4,DisplayName='Data points')
title("Translation @0°")
%axis equal
grid on
xlabel("z[mm]")
ylabel("theta[°]")
%% 
% figure("Name","THETA_30")
subplot(2,3,4,"replace")
[theta_30_model, gof_30, out_30] = fit(sqrt(theta_30_dataset.z.^2+theta_30_dataset.x.^2),abs(theta_30_dataset.pitch),'Poly1',opt);
plot(theta_30_model,sqrt(theta_30_dataset.z.^2+theta_30_dataset.x.^2),abs(theta_30_dataset.pitch))
hold on
% plot(sqrt(theta_30_dataset.z.^2+theta_30_dataset.x.^2),abs(theta_30_dataset.pitch),'*b',MarkerSize=4,DisplayName='Data points')
title("Translation @30°")
%axis equal
grid on
xlabel("z[mm]")
ylabel("theta[°]")
%% 
% figure("Name","THETA_45")
subplot(2,3,5,"replace")
[theta_45_model, gof_45, out_45] = fit(sqrt(theta_45_dataset.z.^2+theta_45_dataset.x.^2),abs(theta_45_dataset.pitch),'Poly1',opt);
plot(theta_45_model,sqrt(theta_45_dataset.z.^2+theta_45_dataset.x.^2),abs(theta_45_dataset.pitch))
hold on
% plot(sqrt(theta_45_dataset.z.^2+theta_45_dataset.x.^2),abs(theta_45_dataset.pitch),'*b',MarkerSize=4,DisplayName='Data points')
title("Translation @45°")
%axis equal
grid on
xlabel("z[mm]")
ylabel("theta[°]")
%% 
% figure("Name","THETA_60")
subplot(2,3,6,"replace[°]")
[theta_60_model, gof_60, out_60] = fit(sqrt(theta_60_dataset.z.^2+theta_60_dataset.x.^2),abs(theta_60_dataset.pitch),'Poly1',opt);
plot(theta_60_model,sqrt(theta_60_dataset.z.^2+theta_60_dataset.x.^2),abs(theta_60_dataset.pitch))
hold on
% plot(sqrt(theta_60_dataset.z.^2+theta_60_dataset.x.^2),abs(theta_60_dataset.pitch),'*b',MarkerSize=4,DisplayName='Data points')
title("Translation @60°")
%axis equal
grid on
xlabel("z[mm]")
ylabel("theta[°]")

%% UNCERTAINTY ASESSMENT

sigma_zx = sqrt(gof_zx.sse/(height(zx_dataset)-out_zx.numparam))
sigma_xz = sqrt(gof_xz.sse/(height(xz_dataset)-out_xz.numparam))
sigma_theta_0 = sqrt(gof_0.sse/(height(xz_dataset)-out_0.numparam))
sigma_theta_30 = sqrt(gof_30.sse/(height(theta_30_dataset)-out_30.numparam))
sigma_theta_45 = sqrt(gof_45.sse/(height(theta_45_dataset)-out_45.numparam))
sigma_theta_60 = sqrt(gof_60.sse/(height(theta_60_dataset)-out_60.numparam))

%% UNCERTAINTY MATRIX
% Use the greatest uncertainty among theta
Uaruco = diag([sigma_zx ...
               sigma_xz ...
               max([sigma_theta_0,sigma_theta_30,sigma_theta_45,sigma_theta_60])]);

writematrix(Uaruco,"../Tests/20231201/04_results/Uaruco.csv")

%% Uncertainty variation over theta
% figure("Name","Theta variance")
% theta = [0 30 45 60];
% plot(theta,[sigma_theta_0 sigma_theta_30 sigma_theta_45 sigma_theta_60])

% As the orientation angle increases the uncertainty decreases, it might be
% because of the sensitivity decrease for greater angles.
