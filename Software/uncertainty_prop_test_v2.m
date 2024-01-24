%% IMPORT DATA

PATH = "../Tests/20231201/03_analysis";
    
% Choose direction between "xz", "zx", "theta_30", "theta_45", "theta_60",
% remember to check the code for adjustments
direction = "xz";

% Translation along x axis
DATASET_ODOMETRY = load(PATH + "/" + direction + "_odom_dataset.mat").xz_dataset;

sigma_odom = readmatrix("../Tests/20231201/04_results/Uodometry.csv");
% 
% %% CALCULATE UNCERTAINTY
% %genero due distribuzioni normali che simulano i dati di accelerazione e
% %velocità angolare
% 
% acc = normrnd(2, 0.4, [1, 343]);
% w = normrnd(0.3, 0.5, [1, 343]);
% nofmeasures = length(acc)
% dt = 1/12;
% theta = [0];
% vel = [0];
% sigma_a = 0.4;
% sigma_w = 0.5;
% for i = 2: (nofmeasures)
%     theta = [theta theta(i-1)+ w(i-1)*dt];
%     vel = [vel vel(i-1)+acc(i-1)*dt];
% end
% 
% %vettori delle varianze delle grandezze lineari e angolari, ponendo
% %la sigma2 attuale come quella del sensore (sigma0)
% sigmax  = [];
% sigma2x = [0 0 0];
% sigma2v = [0 0 0];
% sigma2a =(sigma_a)^2;
% sigma2theta =[ 0 0 0];
% sigma2_w  = (sigma_w)^2;
% for n = 4:(nofmeasures)
%     sigma2v = [sigma2v sigma2v(n-1) + sqrt(sigma2a)];
%     sigma2theta = [sigma2theta sigma2theta(n-1) + sqrt(sigma2_w)];
% end
% for n = 4 :1: (nofmeasures)
%     sigma2x(n) =sigma2x(n-1) + ...
%         (dt^2)*cos(theta(n-2)+w(n-2)*dt)^2*(sigma2v(n-3)+sqrt(sigma2a)*dt^2)+...
%         (9/4)*(dt^4)*cos(theta(n-2)+w(n-2)*dt)^2*sigma2a + ...
%         (vel(n-2)*dt +3/2*acc(n-2)*dt^2)^2*sin(theta(n-2)+w(n-2)*dt)^2*(sigma2theta(n-3)+sigma_w*dt^2)+ ...
%         dt^2*(vel(n-2)*dt + 3/2*acc(n-2)*dt^2)^2*sin(theta(n-2)+w(n-2)*dt)^2*sigma_w^2;
% end
% 
% sigmax = sqrt(sigma2x);
% plot(sigmax)
%% Propagazione errore
% x(i)= x(i-1) +dx*cos(theta(i))
% theta(i) = theta(i-1)+ dtheta
% 
% nota sigmax e sigmatheta per uno spostamento dx, propago:
% 
% sigmax(i)^2 = sigmax(i-1)^2 + sigmax^2 sen(theta)^2*(sigmatheta(i-1)^2 + sigmatheta^2)
n_frames = 700;
Sigma2x = 0.4;
Sigma2theta = 0.2;
theta = normrnd(0, sqrt(Sigma2theta), [1, n_frames]);
sigma2x = [0];
sigma2theta = [0];
for n = 2 : n_frames
    sigma2theta(n) = sigma2theta(n-1) + Sigma2theta;
    sigma2x(n) = sigma2x(n-1) + Sigma2x*sigma2theta(n)*sin(theta(n))^2 +Sigma2x*cos(theta(n))^2;
end
sigmax = sqrt(sigma2x);
plot(sigmax)
