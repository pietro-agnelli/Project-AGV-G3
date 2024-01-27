%% IMPORT DATA

PATH = "../Tests/MARKER_100/FRAME_0.05";

% Get a list of CSV files in the current subdirectory
arucoFiles = dir(fullfile(PATH, '*ARUCO*.csv'));
odomFiles = dir(fullfile(PATH, 'POSE_DATA__2*.csv'));