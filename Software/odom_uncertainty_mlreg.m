% Specify the directory containing subdirectories with CSV files
TEST_DIR = '../Tests/20240130/02_preprocessing';

UXexp = load("../Tests/20240130/04_results/ExpXUncertainty.mat");
UZexp = load("../Tests/20240130/04_results/ExpZUncertainty.mat");
UThetaexp = load("../Tests/20240130/04_results/ExpThetaUncertainty.mat");
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

    for d = [50:50:200, 30,45,60,90]

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
                    xData(n,6) = data.frame(end);
                    xData(n,1) = abs(data.x(end-kmax+k)-data.x(k));
                    xData(n,2) = abs(data.z(end-kmax+k)-data.z(k));
                    xData(n,3) = abs(data.vx(end-100,1));
                    xData(n,4) = abs(data.vz(end-100,1));
                    xData(n,5) = abs(data.yaw(end-kmax+k)-data.yaw(k));
                    xData(n,7) = UXexp.XUncertainty(d/50+1);
                end
                if contains(currentSubdirectory, 'parallel')
                    zData(n,6) = data.frame(end);
                    zData(n,1) = abs(data.x(end-kmax+k)-data.x(k));
                    zData(n,2) = abs(data.z(end-kmax+k)-data.z(k));
                    zData(n,3) = abs(data.vx(end,1));
                    zData(n,4) = abs(data.vz(end,1));
                    zData(n,5) = abs(data.yaw(end-kmax+k)-data.yaw(k));
                    zData(n,7) = UZexp.ZUncertainty(d/50+1);
                end
                if contains(currentSubdirectory, 'angle')
                    ThetaData(na,6) = data.frame(end);
                    ThetaData(na,1) = abs(data.x(end-kmax+k)-data.x(k));
                    ThetaData(na,2) = abs(data.z(end-kmax+k)-data.z(k));
                    ThetaData(na,3) = abs(data.vx(end,1));
                    ThetaData(na,4) = abs(data.vz(end,1));
                    ThetaData(na,5) = abs(data.yaw(end-kmax+k)-data.yaw(k));
                    if d==90
                        ThetaData(na,7) = UThetaexp.UTheta(4);
                    else
                        ThetaData(na,7) = UThetaexp.UTheta(d/15-1);
                    end
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
xMdl = fitlm(xData(:,1:6),xData(:,7),"quadratic");
zMdl = fitlm(zData(:,1:6),zData(:,7),"quadratic");
thetaMdl = fitlm(ThetaData(:,1:6),ThetaData(:,7),"quadratic");

hold on
plot(xData(:,1),xData(:,end),"ob",DisplayName="Actual X uncertainty")
plot(zData(:,2),zData(:,end),"om",DisplayName="Actual Z uncertainty")
plot(xData(:,1),xMdl.Fitted,".c",DisplayName="Predicted X uncertainty")
plot(zData(:,2),zMdl.Fitted,".r",DisplayName="Predicted Z uncertainty")
legend(Location="best")
xlabel("Distance[m]")
ylabel("Uncertainty[m]")
figure
hold on
plot(ThetaData(:,5),ThetaData(:,end),"om",DisplayName="Actual Theta uncertainty")
plot(ThetaData(:,5),thetaMdl.Fitted,".r",DisplayName="Predicted Theta uncertainty")
xlabel("Angle[°]")
ylabel("Uncertainty[°]")
legend(Location="best")

%% Saving results

save("../Tests/20240130/04_results/UncertaintyModels","xMdl","zMdl","thetaMdl")