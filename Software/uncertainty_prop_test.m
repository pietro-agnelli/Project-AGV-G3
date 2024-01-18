%% IMPORT DATA

PATH = "../Tests/20231201/03_analysis";
    
% Choose direction between "xz", "zx", "theta_30", "theta_45", "theta_60",
% remember to check the code for adjustments
direction = "xz";

% Translation along x axis
DATASET_ODOMETRY = load(PATH + "/" + direction + "_odom_dataset.mat").xz_dataset;

sigma_odom = readmatrix("../Tests/20231201/04_results/Uodometry.csv");

%% CALCULATE UNCERTAINTY

odometry_ds = DATASET_ODOMETRY.x;
% zero offset = +-70 mg
sigma0 = 0.4;
sigma = [];
sigma(1) = sigma0;
sigma(2) = 2*sigma(1);
for n = 3:700
    sigma = [sigma sqrt(2*sigma(n-1)^2-sigma(n-2)^2)];
end

plot(sigma)
