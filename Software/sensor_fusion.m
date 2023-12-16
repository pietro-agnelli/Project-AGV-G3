%% IMPORT DATA

PATH = "../Tests/20231201/03_analysis";

% Choose direction between "xz", "zx", "theta_30", "theta_45", "theta_60",
% remember to check the code for adjustments
direction = "xz";

% Translation along x axis
DATASET_ARUCO = load(PATH + "/" + direction + "_dataset.mat").xz_dataset;
DATASET_ODOMETRY = load(PATH + "/" + direction + "_odom_dataset.mat").xz_dataset;

% Alternatively you can read from csv
% DATASET_ARUCO = readtable(PATH+"/theta_45_dataset");
% DATASET_ODOMETRY = readtable(PATH+"/theta_45_odom_dataset");

%% DATA PREPARATION

[~,framesindex] = unique(DATASET_ARUCO.frame);
filtered_aruco = DATASET_ARUCO(framesindex,:);

[~,idx] = ismember(filtered_aruco.frame,DATASET_ODOMETRY.frame);
filtered_odom = DATASET_ODOMETRY(idx,:);

% Since odometry measures are in m and aruco measures are in mm, and odometry
% sets the starting point as origin, we need to apply the starting offset and 
% multiply by 1000
filtered_odom_pitch = filtered_odom.pitch+filtered_aruco.pitch(1);

%% REGRESSION

% Example code for uncertainty calculation
% opt = fitoptions('Method', 'LinearLeastSquares');
% [aruco_model, gof_ar, out_ar] = fit(DATASET_ARUCO.x,DATASET_ARUCO.z,'Poly1',opt);
% [odom_model, gof_odom, out_odom] = fit(DATASET_ODOMETRY.x,DATASET_ODOMETRY.z,'Poly1',opt);
% 
% sigma = [sqrt(gof_ar.sse/(height(filtered_aruco)-out_ar.numparam))
%          sqrt(gof_odom.sse/(height(filtered_odom)-out_odom.numparam))*1000];

%% CLT FUSION

sigma_ar = readmatrix("../Tests/20231201/04_results/Uaruco.csv");
sigma_odom = readmatrix("../Tests/20231201/04_results/Uodometry.csv");
sigma = [sigma_ar(3,3), sigma_odom(3,3)];
[zf, sigmazf] = clt([abs(filtered_aruco.pitch),filtered_odom_pitch], sigma);

%% PLOT RESULTS

plot(zf,'*r',DisplayName="FusedData")
hold on
axis equal
plot(abs(filtered_aruco.pitch),'ob',DisplayName="ArucoData")
plot(filtered_odom_pitch,'+k',DisplayName="OdometryData")
title("CLT Fusion")
legend
