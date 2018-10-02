clear;
format long;

divergeAcc = zeros(20,20);
%paths = [7 8 11 15 19];

%for k = 1 : 5
for g = 14 : 14
for i = 31 : 31
    close all;
    % Separate the bag into GroundTruth and ROVIO messages
     bag = rosbag(convertStringsToChars(strcat('conRand/bag_', string(g), '_', string(i),'.bag')));
    ffImu = select(bag, 'Topic', '/firefly/imu');
    rvOdm = select(bag, 'Topic', '/firefly/rovio/odometry');
    rvTrn = select(bag, 'Topic', '/firefly/rovio/transform');

    % Get the Y GroundTruth and ROVIO possition messages
    rvOdmTrans = timeseries(rvOdm, 'Twist.Twist.Linear.X', 'Twist.Twist.Linear.Y');
    imuDataAnAcc = timeseries(ffImu, 'LinearAcceleration.X', 'LinearAcceleration.Y');
    rvTraTrans = timeseries(rvTrn, 'Transform.Translation.X', 'Transform.Translation.Y');

    % Get the times to start in 0
    rvOdmTrans.Time = rvOdmTrans.Time - rvOdmTrans.Time(1);
    imuDataAnAcc.Time = imuDataAnAcc.Time - imuDataAnAcc.Time(1);
    
    % Preparing IMU data
    bias = mean(imuDataAnAcc.Data(end-99 : end, :));
    imuData = lowpass(imuDataAnAcc.Data - bias, 0.5);
    
    % Preparing ROVIO data
    rvOdmData = diff(rvOdmTrans.Data)/0.25;
    rvOdmData = rvOdmData(end-24 : end, :);
    rvOdmTime = rvOdmTrans.Time(1 : end-1);
    rvOdmTime = rvOdmTime(end-24 : end, :);
        
    % Match the times from ROVIO with GT    
    rvIndexImu = zeros(size(rvOdmTime,1),1);
    for j = 1 : size(rvOdmTime,1)
        [~, rvIndexImu(j)] = min(abs(imuDataAnAcc.Time - rvOdmTime(j)));       
    end
    
    % RMSE
    RMSE = sqrt(mean((imuData(rvIndexImu,:) - rvOdmData).^2));
    
    % Check Boundaries
    BoundCheck = abs(rvTraTrans.Data(end-24 : end, :));
    
    % Check for divergance criteria
    if (RMSE < 0.05 & BoundCheck < 0.3)
        divergeAcc(i - 20, g) = 1;
    elseif (RMSE < 0.1 & BoundCheck < 0.3)
        divergeAcc(i - 20, g) = 2;
    end
   divergeAcc(i - 20, g) 
    
    
%     % Truncate diverging bags and save data
%     idx = size(imuDataAnAcc.Data,1);
%     if diverge(i) == 0
%         idx = find(abs(gtOdmTrans.Data(rvIndex) - rvOdmTrans.Data) > 1.5, 1);
%     end    
%     dlmwrite(convertStringsToChars(strcat('CompData/bag', string(i), '.csv')),[imuDataAnAcc.Time(1:idx) imuDataAnAcc.Data(1:idx,:)],'precision',8);
    

    figure(1)
        subplot(2,1,1)
            plot(rvOdmTime, imuData(rvIndexImu,1));
            hold on;
            plot(rvOdmTime, rvOdmData(:,1));
            legend("IMU","ROVIO")
            xlabel("Time (s)");
            ylabel("X acc (m/s^2)");
            
        subplot(2,1,2)
            plot(rvOdmTime, imuData(rvIndexImu,1));
            hold on;
            plot(rvOdmTime, rvOdmData(:,2));
            legend("IMU","ROVIO")
            xlabel("Time (s)");
            ylabel("Y acc (m/s^2)");
%              
% 
%     
%     diverge(i)
%     waitforbuttonpress;
    
end
end
%end