% Specify the directory containing subdirectories with CSV files
TEST_DIR = '../Tests/20240118/02_preprocessing';

% Get a list of all subdirectories in the main directory
direction_dir = dir(TEST_DIR);
direction_dir = direction_dir([direction_dir.isdir]);  % Keep only directories
direction_dir = direction_dir(~ismember({direction_dir.name}, {'.', '..'}));  % Exclude '.' and '..'

xMeasurments = zeros(10,4);
zMeasurments = zeros(10,4);

% Loop through each subdirectory
for i = 1:length(direction_dir)
    currentSubdirectory = fullfile(TEST_DIR, direction_dir(i).name);

    for d = 50:50:200
        
        % Get a list of all CSV files in the current subdirectory
        csvFiles = dir(fullfile(currentSubdirectory, string(d), 'POSE_DATA__2*.csv'));
        
        for j = 1:length(csvFiles)
        currentCSVFile = fullfile(currentSubdirectory, string(d), csvFiles(j).name);

        % Open the CSV file (you can replace this with your own processing)
        data = readtable(currentCSVFile);

        if contains(currentSubdirectory, 'ortogonal')
            xMeasurments(j,d/50) = abs(data.x(end)-data.x(1));
        else
            zMeasurments(j,d/50) = abs(data.z(end)-data.z(1));
        end

        end

    end

end