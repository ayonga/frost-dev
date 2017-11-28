target_vy = [-0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8];
% target_vy = [0];
target_vx = [-0.4, -0.3, -0.2, -0.1, 0, 0.1, 0.2, 0.3, 0.4];
% target_vx = [0];
subfolder_name = 'library5';



N_mid = 11;%floor(nlp.Phase(1).NumNode/2)+1;
N_vx = length(target_vx);
N_vy = length(target_vy);
% gait = param.gait;
t_all = cell(N_vx, N_vy);
q_all = cell(N_vx, N_vy);
dq_all = cell(N_vx, N_vy);
px_all = cell(N_vx, N_vy);
py_all = cell(N_vx, N_vy);
vx_all = cell(N_vx, N_vy);
vy_all = cell(N_vx, N_vy);
for i = 1:N_vx
    vx = target_vx(i);
    for j = 1:N_vy
        vy = target_vy(j);
        data_name = fullfile('local', subfolder_name, sprintf('gait_X%0.1f_Y%.1f.mat', vx, vy));
        param = load(data_name);
        
        
        t_all{i,j} = [param.gait(3).tspan];%, param.gait(3).tspan];
        q_all{i,j} = [param.gait(3).states.x];%, param. gait(3).states.x];
        dq_all{i,j} = [param.gait(3).states.dx];%, param. gait(3).states.dx];
        px_all{i,j} = [param.gait(3).states.x(1,:)];%ones(size(t_all{i,j}))*vx;
        py_all{i,j} = [param.gait(3).states.x(2,:)];%ones(size(t_all{i,j}))*vy;
        vx_all{i,j} = [param.gait(3).states.dx(1,:)];%ones(size(t_all{i,j}))*vx;
        vy_all{i,j} = [param.gait(3).states.dx(2,:)];%ones(size(t_all{i,j}))*vy;
        
        
    end
    
end

%%
idx = [3:6 7:9, 12:14]; 
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
            dq = dq_all{i,j};
            py = py_all{i,j};
            px = px_all{i,j};
            vy = vy_all{i,j};
            vx = vx_all{i,j};
            scatter3(ax,t, vx,dq(idx(k),:));
%             scatter3(ax,t,vx,q(idx(k),:));
            
        end
        
    end
    
    
end
%%
idx = [7:9, 12:14]; 
for k=1:length(idx)
    f = figure(k+200); clf;
    f.Name = joint_names{idx(k)};
    set(f, 'WindowStyle', 'docked');
    
    ax = axes(f); %#ok<LAXES>
    hold(ax);
    
    for i = 1:N_vx
        for j = 1:N_vy
            t = t_all{i,j};
            q = q_all{i,j};
            dq = dq_all{i,j};
            py = py_all{i,j};
            px = px_all{i,j};
            vy = vy_all{i,j};
            vx = vx_all{i,j};
            plot3(ax, vx(N_mid), vy(N_mid), q(idx(k),N_mid),'*','MarkerSize',4);
%             scatter3(ax,t,vx,q(idx(k),:));
            [S, V] = meshgrid(-0.5:0.01:0.5, -1:0.02:1);
            L = zeros(size(S));
            for ii = 1:size(S, 1)
                for jj = 1:size(S, 2)
                    L(ii, jj) = P(k,:)*[1; S(ii, jj); V(ii, jj)];
                    %L(i, j) = l(n);
                end
            end
            surface(ax, S, V, L);
        end
        
    end
    
    
end

%%
idx = [7:9, 12:14]; 
X = zeros(2, N_vx*N_vy);
Y = zeros(length(idx), N_vx*N_vy); 
dY = zeros(length(idx), N_vx*N_vy); 
ii = 1;
for i = 1:N_vx
    for j = 1:N_vy
        t = t_all{i,j};
        q = q_all{i,j};
        dq = dq_all{i,j};
        
        %         X(:,ii) = [q(1:2,N_mid);dq(1:2,N_mid)];
        X(:,ii) = dq(1:2,N_mid);
        Y(:,ii) = q(idx,N_mid);
        dY(:,ii) = dq(idx,N_mid);
        ii = ii+1;        
    end
end
% x = [ones(1,45); X];
x = [ones(1,81); X];
P = Y/x;
dP = dY/x;

%%
y1 = dY(4,:);
x1 = X(1,:);
x2 = X(2,:);
%%
0.0008997

0.06608

%% Save Training Data
save('Ayonga3DinsertionFunction', 'P','dP')

%% 
% P = zeros(length(idx), 3);
% dP = zeros(length(idx), 3);
% 
% for i=1:length(idx)
%     
%     P(:,i) = Y(i,:)/X;
%     dP(:,i) = dY(i,:)/X;
% end

%%
f = figure(2);clf;
f.Name = 'Sideway Velocity Feature'; 
set(f, 'WindowStyle', 'docked');
ax = axes(f); 
hold(ax);
for i = 1:N_vx
    t = t_all{i,5};
    dq = dq_all{i,5};
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
    t = t_all{3,j};
    dq = dq_all{3,j};
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
    t = t_all{i,5};
    q = q_all{i,5};
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
    t = t_all{3,j};
    q = q_all{3,j};
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
    q = q_all{i,5};
    dq = dq_all{i,5};
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
    q = q_all{3,j};
    dq = dq_all{3,j};
    plot(ax, q(2,:), dq(2,:));    
    plot(ax, q(2,N_mid), dq(2,N_mid),'*','MarkerSize',4);
end
grid on