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
%% CALCULATE UNCERTAINTIES
sigma_ar = readmatrix("../Tests/20231201/04_results/Uaruco.csv");
sigma_odom = readmatrix("../Tests/20231201/04_results/Uodometry.csv");
sigmaz = [sigma_ar(3,3)*ones(height(filtered_aruco),1), uncertainty_prop(sigma_odom(3,3),height(filtered_odom_pitch))'];
%% CLT FUSION
[zf_clt, sigmazf_clt] = clt([abs(filtered_aruco.pitch),filtered_odom_pitch], sigmaz);
%%  BAYES FUSION
close all
x = abs(filtered_aruco.pitch);
z = abs(filtered_odom_pitch);
sigmax = sigma_ar(3,3); 
sigmaz = sigma_odom(3,3);

%distances
pitch = 0:180/343:180;

%devo calcolare la probabilità di una distanza fissata d data la misura x e
%z

Pd_dato_x = 1/(sqrt(2*pi)*sigmax).*exp((-1/2).*(pitch-x).^2/sigmax^2);
Pd_dato_z = 1/(sqrt(2*pi*sigmaz^2))*exp((-1/2).*(pitch-z).^2/sigmaz^2);
Patt_dato_prec = 1/(sqrt(2*pi*4.7^2)).*exp((-1/2)*(-pitch+180).^2/4.7^2);
     
likelihood = Pd_dato_z.*Pd_dato_x.*Patt_dato_prec;

figure
bayes = likelihood./(sum(likelihood).*(180/343));
plot(bayes(2,:))
hold on
plot(Pd_dato_x(2,:))
hold on
plot(Pd_dato_z(2,:))
hold on
zf_bayes = [];
for i = 1:height(bayes)
    raw = bayes(i,:);
    [val, index] = max(raw);
    zf_bayes = [zf_bayes index]
end


%[zf_bayes, sigmazf_bayes] = bayes(abs(filtered_aruco.pitch) , filtered_odom_pitch , sigma_ar(3,3), sigma_odom(3,3));
%% PLOT RESULTS USING CLT FUSION
frames = filtered_aruco.frame;
clt_model = fit(frames,zf_clt,"Poly1");
figure
plot(clt_model,'--g')
hold on
axis equal
plot(frames,zf_clt,'*r',DisplayName="FusedData")
plot(frames,abs(filtered_aruco.pitch),'ob',DisplayName="ArucoData")
plot(frames,filtered_odom_pitch,'+k',DisplayName="OdometryData")
title("CLT Fusion")
legend
%% PLOT RESULTS USING BAYES FUSION
figure
plot(frames, zf_bayes,'*r',DisplayName="FusedData")
hold on
axis equal
plot(frames,abs(filtered_aruco.pitch),'ob',DisplayName="ArucoData")
plot(frames,filtered_odom_pitch,'+k',DisplayName="OdometryData")
title("BAYES Fusion")
legend
% %% uncertainly propagation test
% %sigma2_0 = [sigma2_x0 sigma2_v0 sigma2_a0; sigma2_the0 sigma2_w0 sigma2_alpha0 ]
% sigma2_0 = [sigma]
% sigmax = uncertainty_prop_v2(sigma2_0 ,height(filtered_odom_pitch))
