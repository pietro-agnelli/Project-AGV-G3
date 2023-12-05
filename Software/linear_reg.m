%% IMPORT DATA

PATH = "../Tests/20231201/02_preprocessing";

% Translation along x axis 
DATASET_ZX_PARALLEL_1 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_10_05.csv");
DATASET_ZX_PARALLEL_2 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_14_05.csv");

% Translation along z axis
DATASET_XZ_ORTHO_1 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_06_54.csv");
DATASET_XZ_ORTHO_2 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_09_02.csv");

% Translation 30 deg from z axis
DATASET_THETA_30_1 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_03_14.csv");
DATASET_THETA_30_2 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_05_08.csv");

% Translation 45 deg from z axis
DATASET_THETA_45_1 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_10_59_33.csv");
DATASET_THETA_45_2 = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_01_45.csv");

% Translation 60 deg from z axis
DATASET_THETA_60_1 = readtable(PATH+"\POSE_DATA___ARUCO_2023_12_01_10_55_40.csv");
DATASET_THETA_60_2 = readtable(PATH+"\POSE_DATA___ARUCO_2023_12_01_10_57_50.csv");

%% LINEAR REGRESSION

[zx_model_1, gof1, out1] = fit(DATASET_ZX_PARALLEL_1.z,DATASET_ZX_PARALLEL_1.x,'Poly1')
zx_model_2 = fit(DATASET_ZX_PARALLEL_2.z,DATASET_ZX_PARALLEL_2.x,'Poly1');
plot(zx_model_2,'r')
hold on
plot(zx_model_1,'g')
plot(DATASET_ZX_PARALLEL_1.z,DATASET_ZX_PARALLEL_1.x,'xb',MarkerSize=2)
plot(DATASET_ZX_PARALLEL_2.z,DATASET_ZX_PARALLEL_2.x,'ob',MarkerSize=2)
axis equal
xlabel("z")
ylabel("x")

