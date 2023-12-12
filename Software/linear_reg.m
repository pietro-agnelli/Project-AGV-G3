clear
close all

%% IMPORT DATA

PATH = "../Tests/20231201/02_preprocessing";

% Translation along x axis 
DATASET_ZX_PARALLEL_1 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_10_05.csv");
DATASET_ZX_PARALLEL_2 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_14_05.csv");
zx_dataset = [DATASET_ZX_PARALLEL_1; DATASET_ZX_PARALLEL_2];

% Translation along z axis
DATASET_XZ_ORTHO_1 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_06_54.csv");
DATASET_XZ_ORTHO_2 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_09_02.csv");
xz_dataset = [DATASET_XZ_ORTHO_1; DATASET_XZ_ORTHO_2];

% Translation 30 deg from z axis
DATASET_THETA_30_1 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_03_14.csv");
DATASET_THETA_30_2 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_05_08.csv");
theta_30_dataset = [DATASET_THETA_30_1;DATASET_THETA_30_2];

% Translation 45 deg from z axis
DATASET_THETA_45_1 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_10_59_33.csv");
DATASET_THETA_45_2 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_01_45.csv");
theta_45_dataset = [DATASET_THETA_45_1;DATASET_THETA_45_2];

% Translation 60 deg from z axis
DATASET_THETA_60_1 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_10_55_40.csv");
DATASET_THETA_60_2 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_10_57_50.csv");
theta_60_dataset = [DATASET_THETA_60_1;DATASET_THETA_60_2];

%% LINEAR REGRESSION

% Setting common options for all regressions
opt = fitoptions('Method', 'LinearLeastSquares');

% Plotto x in funzione di z (movimento parallelo al marker)
figure("Name", "XZ")
[zx_model, gof_zx, out_zx] = fit(zx_dataset.x,zx_dataset.z,'Poly1',opt);
plot(zx_model,'r')
hold on
plot(zx_dataset.x,zx_dataset.z,'ob',MarkerSize=4,DisplayName='Data points')
axis equal
xlabel("x")
ylabel("z")
%% 

% Plotto z in funzione di x (movimento ortogonale al marker)
figure("Name","ZX")
[xz_model, gof_xz, out_xz] = fit(xz_dataset.z,xz_dataset.x,'Poly1',opt);
[theta_0_model, gof_0, out_0] = fit(xz_dataset.z, xz_dataset.yaw,'Poly1',opt);
plot(xz_model,'r')
hold on
plot(xz_dataset.z,xz_dataset.x,'ob',MarkerSize=4,DisplayName='Data points')
axis equal
xlabel("z")
ylabel("x")
figure("Name","theta_0")
plot(theta_0_model,'r')
hold on
plot(xz_dataset.z,xz_dataset.yaw,'ob',MarkerSize=4,DisplayName='Data points')
%axis equal
xlabel("z")
ylabel("x")
%% 

% Plotto yaw in funzione di z (movimento ortogonale al marker, guardo come 
% rileva l'angolo (30°) tra marker e telecamera man mano che mi muovo)
figure("Name","THETA_30")
[theta_30_model, gof_30, out_30] = fit(theta_30_dataset.z,theta_30_dataset.yaw,'Poly1',opt);
plot(theta_30_model,'r')
hold on
plot(theta_30_dataset.z,theta_30_dataset.yaw,'ob',MarkerSize=4,DisplayName='Data points')
%axis equal
xlabel("z")
ylabel("yaw")
%% 

figure("Name","THETA_45")
[theta_45_model, gof_45, out_45] = fit(theta_45_dataset.z,theta_45_dataset.yaw,'Poly1',opt);
plot(theta_45_model,'r')
hold on
plot(theta_45_dataset.z,theta_45_dataset.yaw,'ob',MarkerSize=4,DisplayName='Data points')
%axis equal
xlabel("z")
ylabel("yaw")
%% 
figure("Name","THETA_60")
[theta_60_model, gof_60, out_60] = fit(theta_60_dataset.z,theta_60_dataset.yaw,'Poly1',opt);
plot(theta_60_model,'r')
hold on
plot(theta_60_dataset.z,theta_60_dataset.yaw,'ob',MarkerSize=4,DisplayName='Data points')
%axis equal
xlabel("z")
ylabel("yaw")
%%
figure
plot(theta_0_model)
hold on
plot(theta_30_model)
hold on
plot(theta_45_model)
hold on
plot(theta_60_model)

%% UNCERTAINTY ASESSMENT

sigma_zx = sqrt(gof_zx.sse/(height(zx_dataset)-2))
sigma_xz = sqrt(gof_xz.sse/(height(xz_dataset)-2))
sigma_theta_0 = sqrt(gof_0.sse/(height(xz_dataset)-2))
sigma_theta_30 = sqrt(gof_30.sse/(height(theta_30_dataset)-2))
sigma_theta_45 = sqrt(gof_45.sse/(height(theta_45_dataset)-2))
sigma_theta_60 = sqrt(gof_60.sse/(height(theta_60_dataset)-2))
