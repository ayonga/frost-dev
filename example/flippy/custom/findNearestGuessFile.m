function [ret,do_save_new_trajectory] = findNearestGuessFile(name,cur,num_grid,pose_home,pose_start,pose_end)
%     error('Nothing to do here. Code not implemented yet');
    file_name = loadInitialGuessFile(name,cur,num_grid,pose_start,pose_end);
    
    if exist(file_name,'file')
        ret = file_name;
        do_save_new_trajectory = false;
        disp('Existing saved trajectory used as initial guess.');
    else
        pose_end.position = floor(pose_end.position*10)/10;
        file_name = loadInitialGuessFile(name,cur,num_grid,pose_start,pose_end);
        if exist(file_name,'file')
            ret = file_name;
            disp('Using nearest saved trajectory as initial guess.');
        else
            ret = fullfile(cur,'param','random_guess_trajectory.yaml');
            disp('Random trajectory used as intial guess.');
        end
        do_save_new_trajectory = true;
    end
end