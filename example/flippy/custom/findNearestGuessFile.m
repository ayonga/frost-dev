function [ret,trajectory_in_file,file_name] = findNearestGuessFile(cur,num_grid,sub_behavior)
%     Note that the file names contain the behavior name, number of grids,
%     starting and ending position of the spatula only. Orientations,
%     configurations are ignored in the names.
    name = sub_behavior.name;
    pose_start = sub_behavior.pose_start;
    pose_end = sub_behavior.pose_end;
    file_name = loadInitialGuessFile(name,cur,num_grid,pose_start,pose_end);
    
    if exist(file_name,'file')
        ret = file_name;
        disp('Existing saved trajectory used as initial guess.');
        trajectory_in_file = true;
    else
        pose_start_curtailed.position = round(pose_start.position*10)/10;
        pose_end_curtailed.position = round(pose_end.position*10)/10;
        alternate_file_name = loadInitialGuessFile(name,cur,num_grid,pose_start_curtailed,pose_end_curtailed);
        if exist(alternate_file_name,'file')
            ret = alternate_file_name;
            disp('Using nearest saved trajectory as initial guess.');
        else
            random_file_name = fullfile(cur,'param',name,num2str(num_grid),'random_guess_trajectory.yaml');
            if exist(random_file_name,'file')
                ret = random_file_name;
                disp('Random saved trajectory used as intial guess.');
            else
                ret = [];
                disp('No saved trajectory used for initial guess.');
            end
        end
        trajectory_in_file = false;
    end
end