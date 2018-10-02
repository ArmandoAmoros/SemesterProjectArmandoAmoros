clear;
format long;

diverge = zeros(20,20);
load('/home/armando/Desktop/Calibration_Trajectories/init.mat');
%paths = [7 8 11 15 19];

%for k = 1 : 5
for g = 5 : 5
for i = 24 : 24
    close all;
    % Separate the bag into GroundTruth and ROVIO messages
    bag = rosbag(convertStringsToChars(strcat('conRand/bag_', string(g), '_', string(i),'.bag')));
    gtTrans = select(bag, 'Topic', '/firefly/ground_truth/transform');
    rvTrans = select(bag, 'Topic', '/firefly/rovio/transform');
    viImu = select(bag, 'Topic', '/firefly/imu');

    % Get the Y GroundTruth and ROVIO possition messages
    gtTransTrans = timeseries(gtTrans, 'Transform.Translation.X', 'Transform.Translation.Y');
    rvTransTrans = timeseries(rvTrans, 'Transform.Translation.X', 'Transform.Translation.Y');
    imuDataAnAcc = timeseries(viImu, 'AngularVelocity.X', 'AngularVelocity.Y', 'AngularVelocity.Z', ...
                            'LinearAcceleration.X', 'LinearAcceleration.Y', 'LinearAcceleration.Z');

    % Transform ROVIO data with initial conditions
    th = quat2eul([init(1,3:4) 0 0],'XYZ');
    rot = [cos(th(1)) -sin(th(1)) ;sin(th(1)) cos(th(1))]';
    rvTransTrans.Data = rvTransTrans.Data + init(g,1:2) * rot';
    rvTransTrans.Data = rvTransTrans.Data * rot;
    
    % Get the times to start in 0
    gtTransTrans.Time = gtTransTrans.Time - gtTransTrans.Time(1);
    rvTransTrans.Time = rvTransTrans.Time - rvTransTrans.Time(1);
    imuDataAnAcc.Time = imuDataAnAcc.Time - imuDataAnAcc.Time(1);
    
    % Match the times from ROVIO with GT
    rvIndex = zeros(size(rvTransTrans.Time,1),1);
    for j = 1 : size(rvTransTrans.Time,1)
        [~, rvIndex(j)] = min(abs(gtTransTrans.Time - rvTransTrans.Time(j)));       
    end
    
    % RMSE
    RMSE = sqrt(mean((gtTransTrans.Data(rvIndex,:) - rvTransTrans.Data).^2));
    
    % Last error
    LastErrorY = abs(gtTransTrans.Data(rvIndex(end),:) - rvTransTrans.Data(end,:));
    
    % Check for divergance criteria
    if (RMSE < 0.1 & LastErrorY < 0.15)
        diverge(i - 20, g) = 1;
    elseif (RMSE < 0.3 & LastErrorY < 0.3)
        diverge(i - 20, g) = 2;
    end
    diverge(i - 20, g)
    
%     % Truncate diverging bags and save data
%     idx = size(imuDataAnAcc.Data,1);
%     if diverge(i - 20, g) == 0
%         idx = find(abs(gtTransTrans.Data(rvIndex) - rvTransTrans.Data) > 1.5, 1);
%     end    
%     dlmwrite(convertStringsToChars(strcat('CompData/bag', string(i), '.csv')),[imuDataAnAcc.Time(1:idx) imuDataAnAcc.Data(1:idx,:)],'precision',8);
    
    figure(1)
        subplot(2,1,1)
        plot(gtTransTrans.Time, gtTransTrans.Data(:,1));
        hold on;
        plot(rvTransTrans.Time, rvTransTrans.Data(:,1));
        legend("GT","ROVIO")
        xlabel("Time (s)");
        ylabel("X dist (m)");
    
        subplot(2,1,2)
        plot(gtTransTrans.Time, gtTransTrans.Data(:,2));
        hold on;
        plot(rvTransTrans.Time, rvTransTrans.Data(:,2));
        xlabel("Time (s)");
        ylabel("Y dist (m)");
% 
%         subplot(3,1,3) 
%         plot(imuDataAnAcc.Time, imuDataAnAcc.Data(:,4));
%         hold on;
%         plot(imuDataAnAcc.Time, imuDataAnAcc.Data(:,5));
%         plot(imuDataAnAcc.Time, imuDataAnAcc.Data(:,6));
%     
%     diverge(i - 20, g)
%     waitforbuttonpress;
    
end
end
%end