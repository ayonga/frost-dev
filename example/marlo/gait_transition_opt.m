start_vy_series = {[0, 0.2, 0.4, 0.6, 0.8]
    [0, -0.2, -0.4, -0.6, -0.8]
    0
    0};
% start_vy = [0, -0.2, -0.4, -0.6, -0.8];
target_vy = [0.0];
start_vx_series = {0
    0
    [0,0.1,0.2,0.3,0.4]
    [0,-0.1,-0.2,-0.3,-0.4]};
target_vx = [0.0];
T = 0.4;
subfolder_name = 'library5';
if ~exist(fullfile('local', subfolder_name, 'transition'), 'dir')
    mkdir(fullfile('local', subfolder_name, 'transition'));
end

fit_data = load(fullfile('local', subfolder_name, 'midstep_fit.mat'));
P = fit_data.P;
dP = fit_data.dP;

fit_data_right = load(fullfile('local', subfolder_name, 'midstep_fit_right.mat'));
P_right = fit_data_right.P;
dP_right = fit_data_right.dP;
% nlp.Phase(1).removeCost('stateDeviation_RightStance');
% nlp.Phase(3).removeConstraint('periodicState_LeftStance');
start_vy = [-0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8];
start_vx = [-0.4, -0.3, -0.2, -0.1, 0, 0.1, 0.2, 0.3, 0.4];
counter = 1;
for i=1:4
    start_vy = start_vy_series{i};
    start_vx = start_vx_series{i};
    target_gait_file = fullfile('local', subfolder_name, sprintf('gait_X%0.1f_Y%.1f.mat', target_vx, target_vy));
    target_gait = load(target_gait_file);
    guess = [target_gait.gait; target_gait.gait(1:3)];
    guess(3).tspan = guess(3).tspan - guess(3).tspan(1);
    guess(7).tspan = guess(7).tspan - guess(7).tspan(1);
    
    for vx = start_vx
        for vy = start_vy
            
            data_name = fullfile('local', subfolder_name, 'transition', ...
                sprintf('gait_X%0.1f_Y%.1f_TO_X%0.1f_Y%.1f.mat', vx, vy, target_vx, target_vy));
            if exist(data_name, 'file')
                continue;
            end
            
            vel_lb = [min(vx,target_vx), min(vy,target_vy)];
            vel_ub = [max(vx,target_vx), max(vy,target_vy)];
            
            
            
            start_gait_file = fullfile('local', subfolder_name, sprintf('gait_X%0.1f_Y%.1f.mat', vx, vy));
            start_gait = load(start_gait_file);
            x0 = [start_gait.gait(1).states.x(:,11);start_gait.gait(1).states.dx(:,11)];
            
            target_gait_file = fullfile('local', subfolder_name, sprintf('gait_X%0.1f_Y%.1f.mat', target_vx, target_vy));
            target_gait = load(target_gait_file);
            xf = [target_gait.gait(3).states.x(:,11);target_gait.gait(3).states.dx(:,11)];
            
            bounds = trans_opt.GetBounds(robot, vel_lb, vel_ub, T, x0, xf);
            bounds.LeftStance1.midState_QFit = P;
            bounds.LeftStance1.midState_dQFit = dP;
            
            
            bounds.RightStance2.midState_QFit = P_right;
            bounds.RightStance2.midState_dQFit = dP_right;
            
    
            trans_opt.updateVariableBounds(nlp, bounds);
            %             nlp.Phase(3).removeConstraint('periodicState_LeftStance');
            % update desired gaits
            gait_cost = [target_gait.gait(1), target_gait.gait(3), target_gait.gait(1), target_gait.gait(3)];
            trans_opt.updateDesiredGait(nlp, system, gait_cost);
            
            % update initial condition
            
            
            
            trans_opt.updateInitCondition(nlp,guess);
            
            
            
            
            diary_name = fullfile('local', subfolder_name, 'transition', ...
                sprintf('gait_X%0.1f_Y%.1f_TO_X%0.1f_Y%.1f.txt', vx, vy, target_vx, target_vy));
            diary(diary_name);
            
            [gait, sol, info, total_time] = trans_opt.solve(nlp);
            pause(1);
            if info.status == 0 || info.status == 1
                data_name = fullfile('local', subfolder_name, 'transition', ...
                    sprintf('gait_X%0.1f_Y%.1f_TO_X%0.1f_Y%.1f.mat', vx, vy, target_vx, target_vy));
                fprintf('Saving gait %s\n', data_name);
            else
                data_name = fullfile('local', subfolder_name, 'transition', ...
                    sprintf('gait_X%0.1f_Y%.1f_TO_X%0.1f_Y%.1f_Failed.mat', vx, vy, target_vx, target_vy));
                fprintf('Saving (failed) gait %s\n', data_name);
            end
            pause(0.2);
            diary off;
            pause(1);
            save(data_name, 'gait', 'sol', 'info', 'bounds', 'total_time');
            
            
            counter = counter + 1;
            guess = gait;
            
        end
        
    end
end;