% Specify the directory containing subdirectories with CSV files
TEST_DIR = '../Tests/20240130/02_preprocessing';

% Get a list of all subdirectories in the main directory
direction_dir = dir(TEST_DIR);
direction_dir = direction_dir([direction_dir.isdir]);  % Keep only directories
direction_dir = direction_dir(~ismember({direction_dir.name}, {'.', '..'}));  % Exclude '.' and '..'

xMeasurments = zeros(50,4);
zMeasurments = zeros(50,4);
sigma2theta_th = zeros(1,4);
n_frames = zeros(1,4);

sigmaw_th = 1;%incertezza teorica +/- 1°/s
dt = 1/12;

% Loop through each subdirectory
for n = 1:length(direction_dir)
    currentSubdirectory = fullfile(TEST_DIR, direction_dir(n).name);

    for d = 50:50:200

        % Get a list of all CSV files in the current subdirectory
        csvFiles = dir(fullfile(currentSubdirectory, string(d), 'POSE_DATA__2*.csv'));

        for j = 1:length(csvFiles)
            currentCSVFile = fullfile(currentSubdirectory, string(d), csvFiles(j).name)
            csvFiles(j).name;

            % Open the CSV file (you can replace this with your own processing)
            data = readtable(currentCSVFile);
            abs(data.x(end)-data.x(1))
            n_frames(d/50) =n_frames(d/50)+ height(data);
%             figure(10)
%             plot(data.x,data.z)
%             axis equal
%             pause
            kmax = 60;
            for k = 1:kmax
                n = (j-1)*kmax+k;
                if contains(currentSubdirectory, 'ortogonal')
                    xMeasurments(n,d/50) = abs(data.x(end-kmax+k)-data.x(k));
                else
                    zMeasurments(n,d/50) = abs(data.z(end-kmax+k)-data.z(k));
                end
            end
            
        end
        if  or(contains(currentSubdirectory, 'ortogonal'),contains(currentSubdirectory, 'parallel'))
            n_files = height(csvFiles);
            n_frames(d/50) = n_frames(d/50)/n_files;
            sigma2theta_th(d/50) = 0.39^2;
            for i = 2:(height(data))
                sigma2theta_th(d/50) = sigma2theta_th(d/50) +sigmaw_th^2*dt^2;
            end
        end
    end
end

%% VISUALIZATON
nbins = 30;

% %% Z measurement elaboration
% 
% z50Measurements = trimzeros(zMeasurments(:,1)');
% z100Measurements = trimzeros(zMeasurments(:,2)');
% z150Measurements = trimzeros(zMeasurments(:,3)');
% z200Measurements = trimzeros(zMeasurments(:,4)');
% 
% figure(1)
% subplot(2,2,1)
% histogram(z50Measurements,nbins)
% subplot(2,2,2)
% histogram(z100Measurements, nbins)
% subplot(2,2,3)
% histogram(z150Measurements, nbins)
% subplot(2,2,4)
% histogram(z200Measurements, nbins)
% 
% figure(2)
% subplot(2,2,1)
% histogram(z50Measurements-0.50*ones(length(z50Measurements)),nbins)
% subplot(2,2,2)
% histogram(z100Measurements-1.0*ones(length(z100Measurements)), nbins)
% subplot(2,2,3)
% histogram(z150Measurements-1.5*ones(length(z150Measurements)), nbins)
% subplot(2,2,4)
% histogram(z200Measurements-2.0*ones(length(z200Measurements)), nbins)
% 
% E50Z = rmse(z50Measurements,0.50*ones(size(z50Measurements)))
% E100Z = rmse(z100Measurements,1.0*ones(size(z100Measurements)))
% E150Z = rmse(z150Measurements,1.50*ones(size(z150Measurements)))
% E200Z = rmse(z200Measurements,2.00*ones(size(z200Measurements)))
% 
% M50Z = mean(z50Measurements)
% U50Z = std(z50Measurements)
% M100Z = mean(z100Measurements)
% U100Z = std(z100Measurements)
% M150Z = mean(z150Measurements)
% U150Z = std(z150Measurements)
% M200Z = mean(z200Measurements)
% U200Z = std(z200Measurements)

%% X measurement processing

x50Measurements = trimzeros(xMeasurments(:,1)');
x100Measurements = trimzeros(xMeasurments(:,2)');
x150Measurements = trimzeros(xMeasurments(:,3)');
x200Measurements = trimzeros(xMeasurments(:,4)');

U50X = std(x50Measurements)
U100X = std(x100Measurements)
U150X = std(x150Measurements)
U200X = std(x200Measurements)
%% Test sigmadeltaX
sigmaw_th = 1;%incertezza teorica +/- 1°/s

sigma2x =[0.0059 U50X U100X U150X U200X].^2;

sigma2deltax = zeros(1,4);

for n = 2:length(sigma2x)
% sigma2theta_th(n-1) = 0.39^2 + sigmaw_th.^2*(n_frames(n-1)/12).^2;
sigma2deltax(n-1) = (sigma2x(n) - sigma2x(n-1) - 0.5^2 .* sigma2theta_th(n-1).*sin(data.yaw(end)*pi/180).^2)./(cos(data.yaw(end)*pi/180).^2);
end
sigma2theta_th
sqrt(sigma2deltax)
%%
sigma2theta_th(1) = 0;
sigma2deltax(1) = 0;
for n = 2:(height(data))
    sigma2theta_th(n) = sigma2theta_th(n-1) +sigmaw_th^2*dt^2;
    sigma2x(n) = sigma2x(n-1) + (data.x(n)-data.x(n-1))^2 .* sigma2theta_th(n-1).*sin(data.yaw(n-1)*pi/180).^2 + cos(data.yaw(n-1)*pi/180).^2 * 0.0032;
end

plot(sigma2x)
hold on
plot(sigma2theta_th)

%% Test sigmadeltaX
sigmaw_th = 1;%incertezza teorica +/- 1°/s
%dt = 1/12; %framerate
%theta = theta0 + w*dt
%sig2theta = sigma2theta0 + sigma2w*dt^2
% sigma2theta_th = zeros(height(data),1);
% sigma2theta_th(1) = 0.14^2;
% for i = 2:(length(sigma2theta_th))
%     sigma2theta_th(i) = sigma2theta_th(i-1) +sigmaw_th^2*n_frames^2;
% end  


% sigmax(i)^2 = sigmax(i-1)^2 + sigmax^2 sen(theta)^2*(sigmatheta(i-1)^2 + sigmatheta^2)

%sigmax parameter : [sigma50 sigma100 sigma150 sigma200];
%sigmatheta parameter: [sigma0 sigma30 sigma45 sigma60 sigma90]
%theta: current angle
%Sigma2deltax = incognita;

%first of we need to propagate the sigmatheta as
%sigma2theta = sigma2theta(i) - sigma2theta(i-1)
%where
%sigmtheta(i) =[sigma30 sigma45 sigma60 sigma90]
%sigmatheta(i-1) = [sigma0 sigma30 sigma45 sigma60]

sigma2x =[0.0059 U50X U100X U150X U200X].^2;
sigma2theta_th = zeros(1,4);
sigma2deltax = zeros(1,4);
for n = 2:length(sigma2x)
sigma2theta_th(n-1) = 0.39^2 + sigmaw_th.^2*(n_frames(n-1)/12).^2;
sigma2deltax(n-1) = (sigma2x(n) - sigma2x(n-1)^2 - 0.5^2 .* sigma2theta_th(n-1).*sin(data.yaw(end)).^2)./(cos(data.yaw(end)).^2);
end
sigma2theta_th
sigma2deltax
