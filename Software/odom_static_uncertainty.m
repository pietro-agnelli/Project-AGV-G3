% Specify the directory containing subdirectories with CSV files
TEST_DIR = '../Tests/20240130/02_preprocessing';

% Get a list of all subdirectories in the main directory
direction_dir = dir(TEST_DIR);
direction_dir = direction_dir([direction_dir.isdir]);  % Keep only directories
direction_dir = direction_dir(~ismember({direction_dir.name}, {'.', '..'}));  % Exclude '.' and '..'

XstaticMeasurments = zeros(1,50);
ZstaticMeasurments = zeros(1,50);
% Loop through each subdirectory
for ndir = 1:length(direction_dir)
    currentSubdirectory = fullfile(TEST_DIR, direction_dir(ndir).name);

    for d = 50:50:200

        % Get a list of all CSV files in the current subdirectory
        csvFiles = dir(fullfile(currentSubdirectory, string(d), 'POSE_DATA__2*.csv'));

        for j = 1:length(csvFiles)
            currentCSVFile = fullfile(currentSubdirectory, string(d), csvFiles(j).name);
            csvFiles(j).name;

            % Open the CSV file (you can replace this with your own processing)
            data = readtable(currentCSVFile);
            kmax = 48;
            for k = 1:kmax
                n = (j-1)*kmax+k;
                XstaticMeasurments(n+n*(d/50-1)) = data.x(k)-data.x(1);
                ZstaticMeasurments(n+n*(d/50-1)) = data.z(k)-data.z(1);
            end
        end
    end
end

XstaticMeasurments = trimzeros(XstaticMeasurments);
MStaticX = mean(XstaticMeasurments);
UStaticX = sqrt(sum(XstaticMeasurments.^2)/(length(XstaticMeasurments)-1))%std(XstaticMeasurments);
ZstaticMeasurments = trimzeros(ZstaticMeasurments);
MStaticZ = mean(ZstaticMeasurments);
UStaticZ = sqrt(sum(ZstaticMeasurments.^2)/(length(ZstaticMeasurments)-1))%std(ZstaticMeasurments);

figure
plot(XstaticMeasurments,ZstaticMeasurments,'xr')
hold on
error_ellipse(cov(XstaticMeasurments,ZstaticMeasurments), [MStaticX MStaticZ],'conf',0.95,'style','b')
plot(MStaticX,MStaticZ,"ok")
axis equal
grid on
