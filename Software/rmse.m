function rmse = rmse(real,measured)
%RMSE Summary of this function goes here
%   Detailed explanation goes here
rmse = sqrt(mean((real - measured).^2));
end

