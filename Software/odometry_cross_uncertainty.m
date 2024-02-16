% Specify the directory containing subdirectories with CSV files
TEST_DIR = '../Tests/20240130/02_preprocessing';

Ustatic = load("../Tests/20240130/04_results/staticUncertainty.mat");
%%
% Get a list of all subdirectories in the main directory
direction_dir = dir(TEST_DIR);
direction_dir = direction_dir([direction_dir.isdir]);  % Keep only directories
direction_dir = direction_dir(~ismember({direction_dir.name}, {'.', '..'}));  % Exclude '.' and '..'

xMeasurments = zeros(50,4);
zMeasurments = zeros(50,4);
thetaOnOrtoMeas = zeros(50,4);
thetaOnParMeas = zeros(50,4);
% Loop through each subdirectory
for n = 1:length(direction_dir)
    currentSubdirectory = fullfile(TEST_DIR, direction_dir(n).name);

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
            kmax = 12;
            for k = 1:kmax
                n = (j-1)*kmax+k;
                if contains(currentSubdirectory, 'ortogonal')
                    xMeasurments(n,d/50) = abs(data.z(end-kmax+k)-data.z(k));
                    thetaOnOrtoMeas(n,d/50) = abs(data.yaw(end-kmax+k)-data.yaw(k));
                else
                    zMeasurments(n,d/50) = abs(data.x(end-kmax+k)-data.x(k));
                    thetaOnParMeas(n,d/50) = abs(data.yaw(end-kmax+k)-data.yaw(k));
                end
            end
        end
    end
end

%% VISUALIZATON
nbins = 20;

%% Z measurement elaboration
% to calculate uncertainty on x measure due to z
z50Measurements = trimzeros(zMeasurments(:,1)');
z100Measurements = trimzeros(zMeasurments(:,2)');
z150Measurements = trimzeros(zMeasurments(:,3)');
z200Measurements = trimzeros(zMeasurments(:,4)');

thetaz50Measurements = trimzeros(thetaOnParMeas(:,1)');
thetaz100Measurements = trimzeros(thetaOnParMeas(:,2)');
thetaz150Measurements = trimzeros(thetaOnParMeas(:,3)');
thetaz200Measurements = trimzeros(thetaOnParMeas(:,4)');

E50Z = rmse(z50Measurements,0.50*ones(size(z50Measurements)))
E100Z = rmse(z100Measurements,1.0*ones(size(z100Measurements)))
E150Z = rmse(z150Measurements,1.50*ones(size(z150Measurements)))
E200Z = rmse(z200Measurements,2.00*ones(size(z200Measurements)))

M50Z = mean(z50Measurements)
U50Z = std(z50Measurements)
M100Z = mean(z100Measurements)
U100Z = std(z100Measurements)
M150Z = mean(z150Measurements)
U150Z = std(z150Measurements)
M200Z = mean(z200Measurements)
U200Z = std(z200Measurements)
ZUncertainty = [Ustatic.UStaticX U50Z U100Z U150Z U200Z];

UTHETA50Z = mean(thetaz50Measurements)
MTHETA50Z = std(thetaz50Measurements)
UTHETA100Z = mean(thetaz100Measurements)
MTHETA100Z = std(thetaz100Measurements)
UTHETA150Z = mean(thetaz150Measurements)
MTHETA150Z = std(thetaz150Measurements)
UTHETA200Z = mean(thetaz200Measurements)
MTHETA200Z = std(thetaz200Measurements)

ThetaZUncertainty = [Ustatic.UStaticTheta UTHETA50Z UTHETA100Z UTHETA150Z UTHETA200Z];
%% Visualization Z

figure
plot(0:.5:2,ZUncertainty,"-or")
axis equal
grid on
title("Uncertainty on Z measure")
%% X measurement processing

x50Measurements = trimzeros(xMeasurments(:,1)');
x100Measurements = trimzeros(xMeasurments(:,2)');
x150Measurements = trimzeros(xMeasurments(:,3)');
x200Measurements = trimzeros(xMeasurments(:,4)');

thetax50Measurements = trimzeros(thetaOnOrtoMeas(:,1)');
thetax100Measurements = trimzeros(thetaOnOrtoMeas(:,2)');
thetax150Measurements = trimzeros(thetaOnOrtoMeas(:,3)');
thetax200Measurements = trimzeros(thetaOnOrtoMeas(:,4)');

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
XUncertainty = [Ustatic.UStaticZ U50X U100X U150X U200X];

UTHETA50X = mean(thetax50Measurements)
MTHETA50X = std(thetax50Measurements)
UTHETA100X = mean(thetax100Measurements)
MTHETA100X = std(thetax100Measurements)
UTHETA150X = mean(thetax150Measurements)
MTHETA150X = std(thetax150Measurements)
UTHETA200X = mean(thetax200Measurements)
MTHETA200X = std(thetax200Measurements)

ThetaXUncertainty = [Ustatic.UStaticTheta UTHETA50X UTHETA100X UTHETA150X UTHETA200X];
%% Visualization X

figure
plot([Ustatic.MStaticX 0.50 1.00 1.50 2.00],XUncertainty,".-r",MarkerSize=10)
% axis equal
grid on
title("Uncertainty on Z measure")
xlabel("x distance [m]",FontSize=14)
ylabel("z uncertainty [m]",FontSize=14)
ylim([0,0.09])
%% Visualization THETA on X

figure
plot([Ustatic.MStaticX 0.50 1.00 1.50 2.00],ThetaXUncertainty,".-r",MarkerSize=10)
%axis equal
grid on
title("Uncertainty on Theta measure (X)")
xlabel("x distance [m]",FontSize=14)
ylabel("theta uncertainty [°]",FontSize=14)
%% Visualization THETA on Z

figure
plot([Ustatic.MStaticX 0.50 1.00 1.50 2.00],ThetaZUncertainty,"-or")
%axis equal
grid on
title("Uncertainty on Theta measure (Z)")

% %% Save X data
% % incertezze dovute alla traslazione lungo x
 save("../Tests/20240130/04_results/CrossXUncertainty","XUncertainty","ThetaXUncertainty")
% %% Save Z data
% % incertezze dovute alla traslazione lungo z
 save("../Tests/20240130/04_results/CrossZUncertainty","ZUncertainty", "ThetaZUncertainty")