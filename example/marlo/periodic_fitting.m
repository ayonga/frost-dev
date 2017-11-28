%% Generate best fit function
target_vy = 0.0;%[-0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8];
% target_vy = [0];
target_vx = [-0.4, -0.3, -0.2, -0.1, 0, 0.1, 0.2, 0.3, 0.4];
% target_vx = [0];
T = 0.4;
subfolder_name = 'library4';
if ~exist(fullfile('local', subfolder_name, 'periodic_fitting'), 'dir')
    mkdir(fullfile('local', subfolder_name, 'periodic_fitting'));
end
joint_names = {    'BasePosX'
    'BasePosY'
    'BasePosZ'
    'BaseRotX'
    'BaseRotY'
    'BaseRotZ'
    'qHRight'
    'qARight'
    'qBRight'
    'fourBarARight'
    'fourBarBRight'
    'qHLeft'
    'qALeft'
    'qBLeft'
    'fourBarALeft'
    'fourBarBLeft'};

N = 16;
N_vx = length(target_vx);
N_vy = length(target_vy);
t_all = cell(N_vx, N_vy);
q_all = cell(N_vx, N_vy);
dq_all = cell(N_vx, N_vy);
px_all = cell(N_vx, N_vy);
py_all = cell(N_vx, N_vy);
vx_all = cell(N_vx, N_vy);
vy_all = cell(N_vx, N_vy);
counter = 1;
for i = 1:N_vx
    vx = target_vx(i);
    for j = 1:N_vy
        vy = target_vy(j);
        data_name = fullfile('local', subfolder_name, sprintf('gait_X%0.1f_Y%.1f.mat', vx, vy));
        param = load(data_name);
   
        t_all{i,j} = [param.gait(1).tspan]./T;%, param.gait(3).tspan];
        q_all{i,j} = [param.gait(1).states.x];%, param. gait(3).states.x];
        dq_all{i,j} = [param.gait(1).states.dx];%, param. gait(3).states.dx];
        px_all{i,j} = [param.gait(1).states.x(1,:)];%ones(size(t_all{i,j}))*vx;
        py_all{i,j} = [param.gait(1).states.x(2,:)];%ones(size(t_all{i,j}))*vy;
        vx_all{i,j} = [param.gait(1).states.dx(1,:)];%ones(size(t_all{i,j}))*vx;
        vy_all{i,j} = [param.gait(1).states.dx(2,:)];%ones(size(t_all{i,j}))*vy;
        
        
    end
end

inpt = [horzcat(t_all{:})
%     horzcat(px_all{:})
%     horzcat(py_all{:})
    horzcat(vx_all{:})
%     horzcat(vx_all{:})
    ];
q_outpt = horzcat(q_all{:});
dq_outpt = horzcat(dq_all{:});
%%
for i = 1:N
    q_outpt_specific = q_outpt(i, :);
    dq_outpt_specific = dq_outpt(i, :);
    opt.neuralFitting(q_outpt_specific, inpt, 5, fullfile('local', subfolder_name, 'periodic_fitting', sprintf('sagittal_library_q%i', i)));
    opt.neuralFitting(dq_outpt_specific, inpt, 5, fullfile('local', subfolder_name, 'periodic_fitting', sprintf('sagittal_library_dq%i', i)));
end
addpath(fullfile('local', subfolder_name, 'periodic_fitting'));
%% Plot features
% joint angle
for n = 1:N
    f = figure(1000+n);
    f.Name = joint_names{n};
    set(f, 'WindowStyle', 'docked');
    
    ax = axes(f);
    hold(ax);
    
    scatter3(ax, inpt(1,:),inpt(2,:),q_outpt(n,:), 'r');
    
    [S, V] = meshgrid(0:0.01:1, -2:0.01:2);
    L = zeros(size(S));
    for i = 1:size(S, 1)
        for j = 1:size(S, 2)
            L(i, j) = feval(sprintf('sagittal_library_q%i', n), ([S(i, j); V(i, j)]));
            %L(i, j) = l(n);
        end
    end
    
    surface(ax, S, V, L);
end
%% joint velocity
for n = 1:N
    f = figure(2000+n);
    f.Name = joint_names{n};
    set(f, 'WindowStyle', 'docked');
    
    ax = axes(f);
    hold(ax);
    
    scatter3(ax, inpt(1,:),inpt(2,:),dq_outpt(n,:), 'r');
    
    [S, V] = meshgrid(0:0.01:1, -2:0.01:2);
    L = zeros(size(S));
    for i = 1:size(S, 1)
        for j = 1:size(S, 2)
            L(i, j) = feval(sprintf('sagittal_library_dq%i', n), ([S(i, j); V(i, j)]));
        end
    end
    
    surface(ax, S, V, L);
end