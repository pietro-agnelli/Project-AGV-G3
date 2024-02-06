% Specify the directory containing subdirectories with CSV files
TEST_DIR = '../Tests/20240130/02_preprocessing';

% Get a list of all subdirectories in the main directory
direction_dir = dir(TEST_DIR);
direction_dir = direction_dir([direction_dir.isdir]);  % Keep only directories
direction_dir = direction_dir(~ismember({direction_dir.name}, {'.', '..'}));  % Exclude '.' and '..'

measurements = zeros(50,4);
lenghts = zeros(1,4);
% Loop through each subdirectory
for i = 1:length(direction_dir)
    currentSubdirectory = fullfile(TEST_DIR, direction_dir(i).name);
    col = 0;
    for d = [30 45 60 90]
        col = col+1;

        % Get a list of all CSV files in the current subdirectory
        csvFiles = dir(fullfile(currentSubdirectory, string(d), 'POSE_DATA__2*.csv'));

        for j = 1:length(csvFiles)
            currentCSVFile = fullfile(currentSubdirectory, string(d), csvFiles(j).name)
            csvFiles(j).name;

            % Open the CSV file (you can replace this with your own processing)
            data = readtable(currentCSVFile);
            lenghts(1,col) = lenghts(1,col)+height(data);
%             abs(data.yaw(end)-data.yaw(1))
% 
%             figure(10)
%             plot(data.yaw)
%             axis equal
%             pause
            kmax = 48;
            for k = 1:kmax
                id = (j-1)*kmax+k;
                if contains(currentSubdirectory, 'angle')
                    measurements(id,col) = abs(data.yaw(end-kmax+k)-data.yaw(k));
                end
            end
        end
        %lenghts(1,col) =  lenghts(1,col)/j-120
    end
end

%% VISUALIZATON
nbins = 30;

%% Z measurement elaboration

theta30Measurements = trimzeros(measurements(:,1)');
theta45Measurements = trimzeros(measurements(:,2)');
theta60Measurements = trimzeros(measurements(:,3)');
theta90Measurements = trimzeros(measurements(:,4)');

figure(1)
subplot(2,2,1)
histogram(theta30Measurements, nbins)
subplot(2,2,2)
histogram(theta45Measurements, nbins)
subplot(2,2,3)
histogram(theta60Measurements, nbins)
subplot(2,2,4)
histogram(theta90Measurements, nbins)

figure(2)
subplot(2,2,1)
histogram(theta30Measurements-30,nbins)
subplot(2,2,2)
histogram(theta45Measurements-45, nbins)
subplot(2,2,3)
histogram(theta60Measurements-60, nbins)
subplot(2,2,4)
histogram(theta90Measurements-90, nbins)

Etheta30 = rmse(theta30Measurements,30*ones(size(theta30Measurements)))
Etheta45 = rmse(theta45Measurements,45*ones(size(theta45Measurements)))
Etheta60 = rmse(theta60Measurements,60*ones(size(theta60Measurements)))
Etheta90 = rmse(theta90Measurements,90*ones(size(theta90Measurements)))

Mtheta30 = mean(theta30Measurements)
Utheta30 = std(theta30Measurements)
Mtheta45 = mean(theta45Measurements)
Utheta45 = std(theta45Measurements)
Mtheta60 = mean(theta60Measurements)
Utheta60 = std(theta60Measurements)
Mtheta90 = mean(theta90Measurements)
Utheta90 = std(theta90Measurements)
%% sigmadx
sigmatheta = [Utheta30,Utheta45,Utheta60,Utheta90];
% sigma2dtheta = [];
% for i = 2:(length(sigmatheta))
%     sigma2dtheta = [sigma2dtheta sigmatheta(i)^2 - sigmatheta(i-1)^2];
% end    
% sigma2dtheta

sigmaw_th = 1;%incertezza teorica +/- 1°/s
dt = 1/12; %framerate
%theta = theta0 + w*dt
%sig2theta = sigma2theta0 + sigma2w*dt^2
sigma2theta_th = zeros(height(data),1);
sigma2theta_th(1) = 0.14^2;
for i = 2:(length(sigma2theta_th))
    sigma2theta_th(i) = sigma2theta_th(i-1) +sigmaw_th^2*dt^2;
end  
figure
sigma2theta_th
plot(sqrt(sigma2theta_th))
hold on
plot([79.9000   61.5000   87.0000   91.8182], sigmatheta, "o")
