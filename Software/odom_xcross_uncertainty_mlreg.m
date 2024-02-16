% Specify the directory containing subdirectories with CSV files
TEST_DIR = '../Tests/20240130/02_preprocessing';

UXexp = load("../Tests/20240130/04_results/ExpXUncertainty.mat");
load("../Tests/20240130/04_results/CrossXUncertainty.mat")
UZexp = XUncertainty;
UThetaexp = ThetaXUncertainty;
%% Data preparation
% Get a list of all subdirectories in the main directory
direction_dir = dir(TEST_DIR);
direction_dir = direction_dir([direction_dir.isdir]);  % Keep only directories
direction_dir = direction_dir(~ismember({direction_dir.name}, {'.', '..'}));  % Exclude '.' and '..'

xData = zeros(50,6);
zData = zeros(50,6);
ThetaData = zeros(50,6);
% Loop through each subdirectory
for nfile = 1:length(direction_dir)
    currentSubdirectory = fullfile(TEST_DIR, direction_dir(nfile).name);

    for d = 50:50:200

        % Get a list of all CSV files in the current subdirectory
        csvFiles = dir(fullfile(currentSubdirectory, string(d), 'POSE_DATA__2*.csv'));

        for j = 1:length(csvFiles)
            currentCSVFile = fullfile(currentSubdirectory, string(d), csvFiles(j).name);
            csvFiles(j).name;

            % Open the CSV file (you can replace this with your own processing)
            data = readtable(currentCSVFile);
            if ~contains(currentSubdirectory, 'parallel')
                kmax = 48;
            else
                kmax = 12;
            end
            for k = 1:kmax
                if ~contains(currentSubdirectory, 'angle')
                    n = ((d/50-1)*length(csvFiles)+j-1)*kmax+k;
                else
                    na = ((d/15-2)*length(csvFiles)+j-1)*kmax+k;
                end
                if contains(currentSubdirectory, 'ortogonal')
                    %xData(n,6) = data.frame(end);
                    xData(n,1) = abs(data.x(end-kmax+k)-data.x(k));
                    xData(n,2) = abs(data.z(end-kmax+k)-data.z(k));
                    xData(n,3) = abs(mean(data.vx(60:end-60)));
                    xData(n,4) = abs(mean(data.vz(60:end-60)));
                    xData(n,5) = abs(data.yaw(end-kmax+k)-data.yaw(k));
                    xData(n,6) = UXexp.XUncertainty(d/50+1);
                    %zData(n,6) = data.frame(end);
                    zData(n,1) = abs(data.x(end-kmax+k)-data.x(k));
                    zData(n,2) = abs(data.z(end-kmax+k)-data.z(k));
                    zData(n,3) = abs(mean(data.vx));
                    zData(n,4) = abs(mean(data.vz));
                    zData(n,5) = abs(data.yaw(end-kmax+k)-data.yaw(k));
                    zData(n,6) = UZexp(d/50+1);
                    %ThetaData(na,6) = data.frame(end);
                    ThetaData(n,1) = abs(data.x(end-kmax+k)-data.x(k));
                    ThetaData(n,2) = abs(data.z(end-kmax+k)-data.z(k));
                    ThetaData(n,3) = abs(mean(data.vx(60:end-60)));
                    ThetaData(n,4) = abs(mean(data.vz(60:end-60)));
                    ThetaData(n,5) = abs(data.yaw(end-kmax+k)-data.yaw(k));
                    ThetaData(n,6) = UThetaexp(d/50+1);
                end
            end
        end
    end
end

% removing zeros rows
xData = xData(all(xData,2),:);
zData = zData(all(zData,2),:);
ThetaData = ThetaData(all(ThetaData,2),:);

%% Fitting linear regression
xMdl = fitlm(xData(:,1:5),xData(:,end),"linear");
CrossZMdl = fitlm(zData(:,1:5),zData(:,end),"linear");
CrossThetaMdl = fitlm(ThetaData(:,1:5),ThetaData(:,end),"linear", RobustOpts="bisquare");

hold on
plot(xData(:,1),xData(:,end),"ob",DisplayName="Actual X uncertainty")
plot(xData(:,1),zData(:,end),"om",DisplayName="Actual Z uncertainty")
plot(xData(:,1),xMdl.Fitted,".c",DisplayName="Predicted X uncertainty",MarkerSize=9)
plot(xData(:,1),CrossZMdl.Fitted,".g",DisplayName="Predicted Z uncertainty",MarkerSize=9)
legend(Location="northwest")
xlabel("x distance[m]",FontSize=14)
ylabel("Uncertainty[m]",FontSize=14)
grid on
title("Translation uncertainty models")
figure
hold on
plot(xData(:,1),ThetaData(:,end),"om",DisplayName="Actual Theta uncertainty")
plot(xData(:,1),CrossThetaMdl.Fitted,".r",DisplayName="Predicted Theta uncertainty")
xlabel("x distance[m]")
ylabel("Uncertainty[°]")
legend(Location="northwest")
title("Rotation uncertainty models")
grid on

%% Test error regression

ds = readtable("../Tests/MARKER_100/FRAME_0.05/POSE_DATA__2023_12_15_12_28_20_FRAME_0.01_PROVA_2.csv");

figure
hold on

pred = predict(xMdl,[ds.x,ds.z,ds.vx,ds.vz,ds.yaw]);
plot(ds.x, pred, '.-c', DisplayName='Predicted x uncertainty')
pred = predict(CrossZMdl,[ds.x,ds.z,ds.vx,ds.vz,ds.yaw]);
plot(ds.x, pred, '.-m', DisplayName='Predicted z uncertainty')
legend(Location="northwest")
title("Predicted uncertainty in real scenario")
grid on
xlabel('x distance [m]',FontSize=14)
ylabel('Uncertainty [m]',FontSize=14)
figure
pred = predict(CrossThetaMdl,[ds.x,ds.z,ds.vx,ds.vz,ds.yaw]);
plot(ds.x, pred, '.-g', DisplayName='Predicted theta uncertainty')
legend(Location="northwest")
title("Predicted uncertainty in real scenario")
grid on
xlabel('x distance [m]')
ylabel('Uncertainty [°]')
% %% Saving results
% 
<<<<<<< HEAD
% save("../Tests/20240130/04_results/CrossUncertaintyModels","xMdl","CrossZMdl","CrossThetaMdl")
%%
norm(xMdl.Residuals{:,1})/norm(xData,2)
norm(CrossZMdl.Residuals{:,1})/norm(zData,2)
norm(CrossThetaMdl.Residuals{:,1})/norm(ThetaData,2)
=======
save("../Tests/20240130/04_results/CrossUncertaintyModels","xMdl","CrossZMdl","CrossThetaMdl")
>>>>>>> 6c6550f0adb55e31f456c0c5a95f2b13ff1ef50a
