% Specify the directory containing subdirectories with CSV files
TEST_DIR = '../Tests/20240130/02_preprocessing';

% Get a list of all subdirectories in the main directory
direction_dir = dir(TEST_DIR);
direction_dir = direction_dir([direction_dir.isdir]);  % Keep only directories
direction_dir = direction_dir(~ismember({direction_dir.name}, {'.', '..'}));  % Exclude '.' and '..'

xMeasurments = zeros(50,4);
zMeasurments = zeros(50,4);

% Loop through each subdirectory
for i = 1:length(direction_dir)
    currentSubdirectory = fullfile(TEST_DIR, direction_dir(i).name);

    for d = 50:50:200

        % Get a list of all CSV files in the current subdirectory
        csvFiles = dir(fullfile(currentSubdirectory, string(d), 'POSE_DATA__2*.csv'));

        for j = 1:length(csvFiles)
            currentCSVFile = fullfile(currentSubdirectory, string(d), csvFiles(j).name)
            csvFiles(j).name;
            
            % Open the CSV file (you can replace this with your own processing)
            data = readtable(currentCSVFile);
            abs(data.x(end)-data.x(1))
            n_frames(1,d/50) = n_frames(1,d/50)+height(data);
%             figure(10)
%             plot(data.x,data.z)
%             axis equal
%             pause
            kmax = 6;
            for k = 1:kmax
                id = (j-1)*kmax+k;
                if contains(currentSubdirectory, 'ortogonal')
                    xMeasurments(id,d/50) = abs(data.x(end-kmax+k)-data.x(k));
                else
                    zMeasurments(id,d/50) = abs(data.z(end-kmax+k)-data.z(k));
                end
            end
        end
        n_frames(1,d/50)= n_frames(1,d/50)/j -120
    end
end


%% X measurement processing

x50Measurements = trimzeros(xMeasurments(:,1)');
x100Measurements = trimzeros(xMeasurments(:,2)');
x150Measurements = trimzeros(xMeasurments(:,3)');
x200Measurements = trimzeros(xMeasurments(:,4)');

E50X = rmse(x50Measurements,0.50*ones(size(x50Measurements)))
E100X = rmse(x100Measurements,1.0*ones(size(x100Measurements)))
E150X = rmse(x150Measurements,1.50*ones(size(x150Measurements)))
E200X = rmse(x200Measurements,2.00*ones(size(x200Measurements)))

M50X = mean(x50Measurements)
U50X = std(x50Measurements)
M100X = mean(x100Measurements)
U100X = std(x100Measurements)
M150X = mean(x150Measurements)
U150X = std(x150Measurements)
M200X = mean(x200Measurements)
U200X = std(x200Measurements)

