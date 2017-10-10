function ret = loadInitialGuessFile(name,cur,num_grid,pose_start,pose_end)
    if nargin < 1
        error('Not enough arguments');
    end
    % use resolution for only upto second digit
    p_start = floor(pose_start.position*100)/100;
    p_end   = floor(pose_end.position*100)/100;
    
    start_string = [strrep(num2str(p_start(1)),'.','p'),'x',...
                    strrep(num2str(p_start(2)),'.','p'),'y',...
                    strrep(num2str(p_start(3)),'.','p'),'z'];
                
    
                
    end_string =   [strrep(num2str(p_end(1)),'.','p'),'x',...
                    strrep(num2str(p_end(2)),'.','p'),'y',...
                    strrep(num2str(p_end(3)),'.','p'),'z'];
    
%     switch(name)
    if any(strcmp(name,{'trans','flip','pickup','j2j'}))
        ret =  [cur,'/param/trans/fanuc_6DOF_guess_',name,'_grids_',...
                num2str(num_grid),'_start_',start_string,'_end_',...
                end_string,'.yaml'];
    else
        error('Invalid sub_behavior_name');
    end
end