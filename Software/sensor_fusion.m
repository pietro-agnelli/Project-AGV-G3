%% IMPORT DATA

PATH = "../Tests/20231201/02_preprocessing";

% Translation along x axis 
DATASET_ARUCO = readtable(PATH+"/POSE_DATA___ARUCO_2023_12_01_11_14_05.csv");
DATASET_ODOMETRY = readtable(PATH+"/POSE_DATA__2023_12_01_11_14_05.csv");
%%
frames = unique(DATASET_ARUCO.frame);
idx = ismember(DATASET_ARUCO.frame,frames);

filtered_aruco = DATASET_ARUCO(idx,:);
idx = ismember(DATASET_ODOMETRY.frame,filtered_aruco.frame);

filtered_odom = DATASET_ODOMETRY(idx,:);

