% Specify the directory containing subdirectories with CSV files
TEST_DIR = '../Tests/20240130/02_preprocessing';

% Get a list of all subdirectories in the main directory
direction_dir = dir(TEST_DIR);
direction_dir = direction_dir([direction_dir.isdir]);  % Keep only directories
direction_dir = direction_dir(~ismember({direction_dir.name}, {'.', '..'}));  % Exclude '.' and '..'

measurements = zeros(50,4);
nframes = zeros(1,4);
% Loop through each subdirectory
for i = 1:length(direction_dir)
    currentSubdirectory = fullfile(TEST_DIR, direction_dir(i).name);
    col = 0;
    for d = [30 45 60 90]
        col = col+1;

        % Get a list of all CSV files in the current subdirectory
        csvFiles = dir(fullfile(currentSubdirectory, string(d), 'POSE_DATA__2*.csv'));

        for j = 1:length(csvFiles)
            currentCSVFile = fullfile(currentSubdirectory, string(d), csvFiles(j).name);
            csvFiles(j).name;

            % Open the CSV file (you can replace this with your own processing)
            data = readtable(currentCSVFile);
            nframes(1,col) = nframes(1,col)+height(data);
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
        if contains(currentSubdirectory, 'angle')
            nframes(1,col) =  nframes(1,col)/j-120;
        end
    end
end

%% Theta measurement elaboration

theta30Measurements = trimzeros(measurements(:,1)');
theta45Measurements = trimzeros(measurements(:,2)');
theta60Measurements = trimzeros(measurements(:,3)');
theta90Measurements = trimzeros(measurements(:,4)');

Utheta30 = std(theta30Measurements)
Utheta45 = std(theta45Measurements)
Utheta60 = std(theta60Measurements)
Utheta90 = std(theta90Measurements)
%% sigmadx
sigmatheta = [Utheta30,Utheta45,Utheta60,Utheta90];
sigmaw_th = 1;%incertezza teorica +/- 1°/s
dt = 1/12; %framerate
%theta = theta0 + w*dt
%sig2theta = sigma2theta0 + sigma2w*dt^2

sigma2theta_th = zeros(height(data),1);
sigma2theta_th(1) = 0.39^2;

for i = 2:(length(sigma2theta_th))
    sigma2theta_th(i) = sigma2theta_th(i-1) +sigmaw_th^2*dt^2;
end  
figure
sigma2theta_th
plot(sqrt(sigma2theta_th))
hold on
plot(nframes, sigmatheta, "o")
