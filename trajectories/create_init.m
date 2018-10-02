clear all
num = 20;

formatSpec = 'P%d,%1.5f,%1.5f,%1.5f,%1.5f,%1.5f,%1.5f,%1.5f,\n';
name = string(1000);


    x1 = round((6 * rand(num,1)) - 3, 2);
    x2 = round((6 * rand(num,1)) - 3, 2);
    x3 = round((2 * pi * rand(num,1)), 2);
    fileID = fopen(strcat('traj_', name, '.csv'),'w');
    fprintf(fileID,formatSpec,[[1:num]',x1,x2,2*ones(num,1),fliplr(eul2quat([x3 zeros(num,2)],'XYZ'))]');
    fclose(fileID);

