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
DATASET_THETA_60_1 = readtable(PATH+"\POSE_DATA___ARUCO_2023_12_01_10_55_40.csv");
DATASET_THETA_60_2 = readtable(PATH+"\POSE_DATA___ARUCO_2023_12_01_10_57_50.csv");
theta_60_dataset = [DATASET_THETA_60_1;DATASET_THETA_60_2];

%% LINEAR REGRESSION

% Setting common options for all regressions
opt = fitoptions('Method', 'LinearLeastSquares');

[zx_model, gof1, out1] = fit(zx_dataset.z,zx_dataset.x,'Poly1',opt);
plot(zx_model,'r')
hold on
plot(zx_dataset.z,zx_dataset.x,'ob',MarkerSize=4,DisplayName='Data points')
axis equal
xlabel("z")
ylabel("x")

