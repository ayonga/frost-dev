target_vy = [-0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8];
% target_vy = [0];
target_vx = [-0.4, -0.3, -0.2, -0.1, 0, 0.1, 0.2, 0.3, 0.4];
% target_vx = [0];
T = 0.4;
subfolder_name = 'library5';
if ~exist(fullfile('local', subfolder_name), 'dir')
    mkdir(fullfile('local', subfolder_name));
end

counter = 1;

param = load('local/good_gait.mat');
% gait = param.gait;
for vx = target_vx
    for vy = target_vy
%         if vy ~= 0 
%             continue;
%         end
        %
        %         data_name = fullfile('local', subfolder_name, sprintf('gait_X%0.1f_Y%.1f.mat', vx, vy));
        %
        %         if exist(data_name,'file')
        %             continue;
        %         end
        
        speed = [vx, vy];
        bounds = opt.GetBounds(robot, speed, T);
        opt.updateVariableBounds(nlp, bounds);
        % update initial condition
        opt.updateInitCondition(nlp,param.gait);
        
                
        diary_name = fullfile('local', subfolder_name, sprintf('gait_X%0.1f_Y%.1f.txt', vx, vy));
        diary(diary_name);
        
        [gait, sol, info] = opt.solve(nlp, param.sol, param.info);
        pause(1);
        if info.status == 0 || info.status == 1
            data_name = fullfile('local', subfolder_name, sprintf('gait_X%0.1f_Y%.1f.mat', vx, vy));
            fprintf('Saving gait %s\n', data_name);
        else
            data_name = fullfile('local', subfolder_name, sprintf('gait_X%0.1f_Y%.1f_FAILED.mat', vx, vy));
            fprintf('Saving (failed) gait %s\n', data_name);
        end
        pause(0.2);
        diary off;
        pause(1);
        save(data_name, 'gait', 'sol', 'info', 'bounds', 'speed');

        
        counter = counter + 1;
        
    end
end

