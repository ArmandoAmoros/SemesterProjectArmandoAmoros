clear all
num = 5;
files = 40;

formatSpec = 'P%d,%1.5f,%1.5f,%1.5f,%1.5f,%1.5f,%1.5f,%1.5f,\n';
name = string(1:files);

for i=21:40
    x1 = round((.6 * rand(num,1)) - .3, 2);
    x2 = round((.6 * rand(num,1)) - .3, 2);
    fileID = fopen(strcat('traj_', name(i), '.csv'),'w');
    %fprintf(fileID,'1,\n');
    fprintf(fileID,'P0,0.00000,0.00000,2.00000,0.00000,0.00000,0.00000,1.00000,\n');
    fprintf(fileID,formatSpec,[[1:num]',x1,x2,2*ones(num,1),zeros(num,1),zeros(num,1),zeros(num,1),ones(num,1)]');
    fprintf(fileID,'P%d,0.00000,0.00000,2.00000,0.00000,0.00000,0.00000,1.00000,\n', num+1);
    %fprintf(fileID,'P%d,0.00000,-3.00000,2.00000,0.00000,0.00000,0.00000,1.00000,\n', num+2);
    fclose(fileID);
end