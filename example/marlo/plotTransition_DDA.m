start_vy = 0.0;
% start_vy = [-0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8];
target_vy = [0.0];
% start_vx = 0.0;
start_vx = [-0.4, -0.3, -0.2, -0.1, 0.0, 0.1, 0.2, 0.3, 0.4];
target_vx = [0.0];
subfolder_name = 'library4';

plot_single_step = true;

N_mid = 11;%floor(nlp.Phase(1).NumNode/2)+1;
N_vx = length(start_vx);
N_vy = length(start_vy);
% gait = param.gait;
t_all = cell(N_vx, N_vy);
q_all = cell(N_vx, N_vy);
dq_all = cell(N_vx, N_vy);
px_all = cell(N_vx, N_vy);
py_all = cell(N_vx, N_vy);
vx_all = cell(N_vx, N_vy);
vy_all = cell(N_vx, N_vy);
alpha_all = cell(N_vx, N_vy);
for i = 1:N_vx
    vx = start_vx(i);
    for j = 1:N_vy
        vy = start_vy(j);
        data_name = fullfile('local', subfolder_name, 'transition', ...
                sprintf('gait_X%0.1f_Y%.1f_TO_X%0.1f_Y%.1f.mat', vx, vy, target_vx, target_vy));
        param = load(data_name);
        
        if ~plot_single_step
            t_all{i,j} = [param.gait(1).tspan, param.gait(3).tspan, ...
                param.gait(5).tspan, param.gait(7).tspan];
            q_all{i,j} = [param.gait(1).states.x, param. gait(3).states.x,...
                param.gait(5).states.x, param. gait(7).states.x];
            dq_all{i,j} = [param.gait(1).states.dx, param. gait(3).states.dx,...
                param.gait(5).states.dx, param. gait(7).states.dx];
            px_all{i,j} = [param.gait(1).states.x(1,:),param.gait(3).states.x(1,:),...
                param.gait(5).states.x(1,:),param.gait(7).states.x(1,:)];
            py_all{i,j} = [param.gait(1).states.x(2,:),param.gait(3).states.x(2,:),...
                param.gait(5).states.x(2,:),param.gait(7).states.x(2,:)];
            vx_all{i,j} = [param.gait(1).states.dx(1,:),param.gait(3).states.dx(1,:),...
                param.gait(5).states.dx(1,:),param.gait(7).states.dx(1,:)];
            vy_all{i,j} = [param.gait(1).states.dx(2,:),param.gait(3).states.dx(2,:),...
                param.gait(5).states.x(2,:),param.gait(7).states.x(2,:)];
        else
            t_all{i,j} = [param.gait(1).tspan];%, param.gait(3).tspan];
            q_all{i,j} = [param.gait(1).states.x];%, param. gait(3).states.x];
            dq_all{i,j} = [param.gait(1).states.dx];%, param. gait(3).states.dx];
            px_all{i,j} = [param.gait(1).states.x(1,:)];%ones(size(t_all{i,j}))*vx;
            py_all{i,j} = [param.gait(1).states.x(2,:)];%ones(size(t_all{i,j}))*vy;
            vx_all{i,j} = [param.gait(1).states.dx(1,:)];%ones(size(t_all{i,j}))*vx;
            vy_all{i,j} = [param.gait(1).states.dx(2,:)];%ones(size(t_all{i,j}))*vy;
			alpha_all{i, j} = [param.gait(1).params.aoutput];
        end
    end
    
end

%% Save Training Data
save('Ayonga3DforwardTransitionGaits', 'alpha_all', 'start_vy','start_vx','t_all','vx_all','vy_all')


%%
idx = [7:9, 12:14]; 

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
for k=1:length(idx)
    f = figure(k+100); clf;
    f.Name = joint_names{idx(k)};
    set(f, 'WindowStyle', 'docked');
    
    ax = axes(f); %#ok<LAXES>
    hold(ax);
    
    for i = 1:N_vx
        for j = 1:N_vy
            t = t_all{i,j};
            q = q_all{i,j};
            vy = vy_all{i,j};
            vx = vx_all{i,j};
            
            scatter3(ax,t,vy,q(idx(k),:));
            %             scatter3(ax,t,vx,q(idx(k),:));
            
        end
        
    end
    
    
end

%%
idx = [7:9, 12:14]; 
X = zeros(4, N_vx*N_vy);
Y = zeros(6*2, N_vx*N_vy); 
ii = 1;
for i = 1:N_vx
    for j = 1:N_vy
        t = t_all{i,j};
        q = q_all{i,j};
        dq = dq_all{i,j};
        
        X(:,ii) = [q(1:2,N_mid); dq(1:2,N_mid)];
        Y(:,ii) = [q(idx,N_mid); dq(idx,N_mid)];
        ii = ii+1;        
    end
end
    
  


%%
f = figure(2);clf;
f.Name = 'Sideway Velocity Feature'; 
set(f, 'WindowStyle', 'docked');
ax = axes(f); 
hold(ax);
for i = 1:N_vx
    t = t_all{i};
    dq = dq_all{i};
    plot(ax, t, dq(1,:));  
    plot(ax, t(N_mid), dq(1,N_mid),'*','MarkerSize',4);
end
grid on
%%
f = figure(3);clf;
f.Name = 'Forward Velocity Feature'; 
set(f, 'WindowStyle', 'docked');
ax = axes(f); 
hold(ax);
for j = 1:N_vy
    t = t_all{j};
    dq = dq_all{j};
    plot(ax, t, dq(2,:));    
    plot(ax, t(N_mid), dq(2,N_mid),'*','MarkerSize',4);
end
grid on
%%
f = figure(4);clf;
f.Name = 'Sideway Position Feature'; 
set(f, 'WindowStyle', 'docked');
ax = axes(f); 
hold(ax);
for i = 1:N_vx
    t = t_all{i};
    q = q_all{i};
    plot(ax, t, q(1,:));  
    plot(ax, t(N_mid), q(1,N_mid),'*','MarkerSize',4);
end
grid on
%%
f = figure(5);clf;
f.Name = 'Forward Position Feature'; 
set(f, 'WindowStyle', 'docked');
ax = axes(f); 
hold(ax);
for j = 1:N_vy
    t = t_all{j};
    q = q_all{j};
    plot(ax, t, q(2,:));    
    plot(ax, t(N_mid), q(2,N_mid),'*','MarkerSize',4);
end
grid on

%%
f = figure(6);clf;
f.Name = 'Sideway Position Feature'; 
set(f, 'WindowStyle', 'docked');
ax = axes(f); 
hold(ax);
for i = 1:N_vx
    q = q_all{i};
    dq = dq_all{i};
    plot(ax, q(1,:), dq(1,:));  
    plot(ax, q(1,N_mid), dq(1,N_mid),'*','MarkerSize',4);
end
grid on
%%
f = figure(7);clf;
f.Name = 'Forward Position Feature'; 
set(f, 'WindowStyle', 'docked');
ax = axes(f); 
hold(ax);
for j = 1:N_vy    
    q = q_all{j};
    dq = dq_all{j};
    plot(ax, q(2,:), dq(2,:));    
    plot(ax, q(2,N_mid), dq(2,N_mid),'*','MarkerSize',4);
end
grid on