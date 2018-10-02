clear;
format long;

divergeAcc = zeros(5,5,5);
paths = [7 8 11 15 19];

for k = 1 : 5
for g = 1 : 5
for i = 1 : 5
    close all;
    % Separate the bag into GroundTruth and ROVIO messages
    bag = rosbag(convertStringsToChars(strcat('../CompConRepMsf/bag_', string(k), '_', string(paths(g)), '_', string(i),'.bag')));
    ffImu = select(bag, 'Topic', '/firefly/imu');
    msfOdm = select(bag, 'Topic', '/firefly/msf_core/odometry');
    msfTrn = select(bag, 'Topic', '/firefly/msf_core/pose');

    % Get the Y GroundTruth and ROVIO possition messages
    msfOdmTrans = timeseries(msfOdm, 'Twist.Twist.Linear.X', 'Twist.Twist.Linear.Y');
    imuDataAnAcc = timeseries(ffImu, 'LinearAcceleration.X', 'LinearAcceleration.Y');
    msfPose = timeseries(msfTrn, 'Pose.Pose.Position.X', 'Pose.Pose.Position.Y');

    % Get the times to start in 0
    msfOdmTrans.Time = msfOdmTrans.Time - msfOdmTrans.Time(1);
    imuDataAnAcc.Time = imuDataAnAcc.Time - imuDataAnAcc.Time(1);
    msfPose.Time = msfPose.Time - msfPose.Time(1);
    
    % Preparing IMU data
    bias = mean(imuDataAnAcc.Data(end-99 : end, :));
    imuData = lowpass(imuDataAnAcc.Data - bias, 0.5);
    
    % Preparing MSF data
    msfOdmData = diff(msfOdmTrans.Data)./(0.01./diff(msfOdmTrans.Time));
    msfOdmData = msfOdmData(end-100 : end, :);
    msfOdmTime = msfOdmTrans.Time(1 : end-1);
    msfOdmTime = msfOdmTime(end-100 : end, :);
        
    % Match the times from ROVIO with GT    
    rvIndexImu = zeros(size(msfOdmTime,1),1);
    for j = 1 : size(msfOdmTime,1)
        [~, rvIndexImu(j)] = min(abs(imuDataAnAcc.Time - msfOdmTime(j)));       
    end
    
    % RMSE
    RMSE = sqrt(mean((imuData(rvIndexImu,:) - msfOdmData).^2));
    
    % Check Boundaries
    BoundCheck = abs(msfPose.Data(end-100 : end, :));
    
    % Check for divergance criteria
    if (RMSE < 0.05 & BoundCheck < 0.3)
        divergeAcc(i,g,k) = 1;
    elseif (RMSE < 0.1 & BoundCheck < 0.3)
        divergeAcc(i,g,k) = 2;
    end

   
    
    
%     % Truncate diverging bags and save data
%     idx = size(imuDataAnAcc.Data,1);
%     if diverge(i) == 0
%         idx = find(abs(gtOdmTrans.Data(rvIndex) - rvOdmTrans.Data) > 1.5, 1);
%     end    
%     dlmwrite(convertStringsToChars(strcat('CompData/bag', string(i), '.csv')),[imuDataAnAcc.Time(1:idx) imuDataAnAcc.Data(1:idx,:)],'precision',8);
    
%     figure(1)
%         subplot(2,2,1)
%             %plot(msfPose.Time, msfPose.Data(:,1));
%             %hold on;
%             plot(rvTrans.Time, rvTrans.Data(:,1));
%             
%         subplot(2,2,2)
%             plot(msfPose.Time, msfPose.Data(:,2));
%             hold on;
%             plot(rvTrans.Time, rvTrans.Data(:,2));
%     
% %         subplot(2,2,3) 
% %             plot(imuDataAnAcc.Time(rvIndexImu), lowpass(imuDataAnAcc.Data((rvIndexImu),3), 0.5));
% %             hold on;
% %             plot(rvOdmTrans.Time(1:end-1), diff(rvOdmTrans.Data(:,1))/0.1 - 0.24);
% %             
% %         subplot(2,2,4) 
% %             plot(imuDataAnAcc.Time(rvIndexImu), lowpass(imuDataAnAcc.Data((rvIndexImu),4), 0.5));
% %             hold on;
% %             plot(rvOdmTrans.Time(1:end-1), diff(rvOdmTrans.Data(:,2))/0.1 - 0.16);
%             
%     waitforbuttonpress;
    
end
end
end