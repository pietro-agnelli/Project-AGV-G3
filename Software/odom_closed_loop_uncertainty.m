% Specify the directory containing subdirectories with CSV files
TEST_DIR = '../Tests/20240118/02_preprocessing';

% Get a list of all subdirectories in the main directory
direction_dir = dir(TEST_DIR);
direction_dir = direction_dir([direction_dir.isdir]);  % Keep only directories
direction_dir = direction_dir(~ismember({direction_dir.name}, {'.', '..'}));  % Exclude '.' and '..'

xMeasurmentsX = zeros(50,4);
xMeasurmentsZ = zeros(50,4);
zMeasurmentsX = zeros(50,4);
zMeasurmentsZ = zeros(50,4);
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
%             abs(data.x(end)-data.x(1))
%             figure(10)
%             plot(data.x,data.z)
%             axis equal
%             pause
            kmax = 10;
            for k = 1:kmax
                n = (j-1)*kmax+k;
                if contains(currentSubdirectory, 'ortogonal')
                    if j == 1
                        xZero = data.x(1);
                        zZero = data.z(1);
                    end
                    xMeasurmentsX(n,d/50) = data.x(k) - xZero;
                    xMeasurmentsZ(n,d/50) = data.z(k) - zZero;
                else
                    if j == 1
                        xZero = data.x(1);
                        zZero = data.z(1);
                    end
                    zMeasurmentsX(n,d/50) = data.x(k) - xZero;
                    zMeasurmentsZ(n,d/50) = data.z(k) - zZero;
                end
            end
        end
    end
end

%% Z measurement elaboration

z50MeasurmentsX = trimzeros(zMeasurmentsX(:,1)');
z100MeasurmentsX = trimzeros(zMeasurmentsX(:,2)');
z150MeasurmentsX = trimzeros(zMeasurmentsX(:,3)');
z200MeasurmentsX = trimzeros(zMeasurmentsX(:,4)');

z50MeasurmentsZ = trimzeros(zMeasurmentsZ(:,1)');
z100MeasurmentsZ = trimzeros(zMeasurmentsZ(:,2)');
z150MeasurmentsZ = trimzeros(zMeasurmentsZ(:,3)');
z200MeasurmentsZ = trimzeros(zMeasurmentsZ(:,4)');

M50Z = [mean(z50MeasurmentsX) mean(z50MeasurmentsZ)] 
U50Z = [std(z50MeasurmentsX) std(z50MeasurmentsZ)]
M100Z = [mean(z100MeasurmentsX) mean(z100MeasurmentsZ)] 
U100Z = [std(z100MeasurmentsX) std(z100MeasurmentsX)]
M150Z = [mean(z150MeasurmentsX) mean(z150MeasurmentsX)] 
U150Z = [std(z150MeasurmentsX) std(z150MeasurmentsX)]
M200Z = [mean(z200MeasurmentsX) mean(z200MeasurmentsX)] 
U200Z = [std(z200MeasurmentsX) std(z200MeasurmentsX)]

figure
subplot(2,2,1)
plot(z50MeasurmentsX,z50MeasurmentsZ,'xr')
hold on
error_ellipse(cov(diag(U50Z)), M50Z,'conf',0.95,'style','b')
axis equal

subplot(2,2,2)
plot(z100MeasurmentsX,z100MeasurmentsZ,'xr')
hold on
error_ellipse(cov(diag(U100Z)), M100Z,'conf',0.95,'style','b')
axis equal

subplot(2,2,3)
plot(z150MeasurmentsX,z150MeasurmentsZ,'xr')
hold on
error_ellipse(cov(diag(U150Z)), M150Z,'conf',0.95,'style','b')
axis equal

subplot(2,2,4)
plot(z200MeasurmentsX,z200MeasurmentsZ,'xr')
hold on
error_ellipse(cov(diag(U200Z)), M200Z,'conf',0.95,'style','b')
axis equal
%% X measurement processing

x50Measurments = trimzeros(xMeasurmentsX(:,1)');
x100Measurments = trimzeros(xMeasurmentsX(:,2)');
x150Measurments = trimzeros(xMeasurmentsX(:,3)');
x200Measurments = trimzeros(xMeasurmentsX(:,4)');

E50X = rmse(x50Measurments,0.50*ones(size(x50Measurments)))
E100X = rmse(x100Measurments,1.0*ones(size(x100Measurments)))
E150X = rmse(x150Measurments,1.50*ones(size(x150Measurments)))
E200X = rmse(x200Measurments,2.00*ones(size(x200Measurments)))

M50X = mean(x50Measurments)
U50X = std(x50Measurments)
M100X = mean(x100Measurments)
U100X = std(x100Measurments)
M150X = mean(x150Measurments)
U150X = std(x150Measurments)
M200X = mean(x200Measurments)
U200X = std(x200Measurments)