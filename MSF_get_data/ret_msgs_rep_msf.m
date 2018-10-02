clear;
format long;

diverge = zeros(5,5,5);
load('/home/armando/Desktop/Calibration_Trajectories/init2.mat');
paths = [7 8 11 15 19];

for k = 1 : 5
for g = 1 : 5
for i = 1 : 5
    close all;
    % Separate the bag into GroundTruth and ROVIO messages
    bag = rosbag(convertStringsToChars(strcat('../CompConRepMsf/bag_', string(k), '_', string(paths(g)), '_', string(i),'.bag')));
    gtTrans = select(bag, 'Topic', '/firefly/ground_truth/transform');
    msfTrn = select(bag, 'Topic', '/firefly/msf_core/pose');

    % Get the Y GroundTruth and ROVIO possition messages
    gtTransTrans = timeseries(gtTrans, 'Transform.Translation.X', 'Transform.Translation.Y');
    msfPose = timeseries(msfTrn, 'Pose.Pose.Position.X', 'Pose.Pose.Position.Y');

    % Transform ROVIO data with initial conditions
%     th = quat2eul([init(1,3:4) 0 0],'XYZ');
%     rot = [cos(th(1)) -sin(th(1)) ;sin(th(1)) cos(th(1))]';
%     rvTransTrans.Data = rvTransTrans.Data + init(g,1:2) * rot';
%     rvTransTrans.Data = rvTransTrans.Data * rot;
    
    % Get the times to start in 0
    gtTransTrans.Time = gtTransTrans.Time - gtTransTrans.Time(1);
    msfPose.Time = msfPose.Time - msfPose.Time(1);
    
    % Match the times from ROVIO with GT
    rvIndex = zeros(size(msfPose.Time,1),1);
    for j = 1 : size(msfPose.Time,1)
        [~, rvIndex(j)] = min(abs(gtTransTrans.Time - msfPose.Time(j)));       
    end
    
    % RMSE
    RMSE = sqrt(mean((gtTransTrans.Data(rvIndex,:) - msfPose.Data).^2));
    
    % Last error
    LastErrorY = abs(gtTransTrans.Data(rvIndex(end),:) - msfPose.Data(end,:));
    
    % Check for divergance criteria
    if (RMSE < 0.1 & LastErrorY < 0.15)
        diverge(i,g,k) = 1;
    elseif (RMSE < 0.3 & LastErrorY < 0.3)
        diverge(i,g,k) = 2;
    end
    
%     % Truncate diverging bags and save data
%     idx = size(imuDataAnAcc.Data,1);
%     if diverge(i) == 0
%         idx = find(abs(gtTransTrans.Data(rvIndex) - rvTransTrans.Data) > 1.5, 1);
%     end    
%     dlmwrite(convertStringsToChars(strcat('CompData/bag', string(i), '.csv')),[imuDataAnAcc.Time(1:idx) imuDataAnAcc.Data(1:idx,:)],'precision',8);
    
%     figure(1)
%         subplot(3,1,1)
%         plot(gtTransTrans.Time, gtTransTrans.Data(:,1));
%         hold on;
%         plot(msfPose.Time, msfPose.Data(:,1));
%     
%         subplot(3,1,2) 
%         plot(gtTransTrans.Time, gtTransTrans.Data(:,2));
%         hold on;
%         plot(msfPose.Time, msfPose.Data(:,2));
% % 
% %         subplot(3,1,3) 
% %         plot(imuDataAnAcc.Time, imuDataAnAcc.Data(:,4));
% %         hold on;
% %         plot(imuDataAnAcc.Time, imuDataAnAcc.Data(:,5));
% %         plot(imuDataAnAcc.Time, imuDataAnAcc.Data(:,6));
% %     
%   
%     waitforbuttonpress;
    
end
end
end