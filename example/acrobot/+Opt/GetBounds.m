function bounds= GetBounds(sys)
    %GET_BOUNDS Summary of this function goes here
    %   Detailed explanation goes here
    
    if isa(sys,'HybridSystem')
        is_hybrid = true;
        robot = sys.Gamma.Nodes.Domain{1};
    else
        is_hybrid = false;
        robot = sys;
    end
    
    
    
    bounds = robot.getLimits();
    
    bounds.time.t0.lb = 0; % starting time
    bounds.time.t0.ub = 0;
    bounds.time.t0.x0 = 0;
    bounds.time.tf.lb = 0; % terminating time
    bounds.time.tf.ub = 10;
    bounds.time.tf.x0 = 0.5;
    bounds.time.duration.lb = 0.5; % duration (optional)
    bounds.time.duration.ub = 0.5;
    
    %     bounds.states.x.terminal = zeros(6,1);
    %     bounds.states.dx.terminal = zeros(6,1);
    %     bounds.states.ddx.terminal = zeros(6,1);
    %     bounds.states.dx.ub = zeros(6,1);
    %     bounds.states.dx.x0 = zeros(6,1);
    
    bounds.gain.kp = 100;
    bounds.gain.kd = 20;
    
    bounds.params.ajoints.ub = reshape(ones(3,6)*pi,[],1);
    bounds.params.ajoints.lb = reshape(ones(3,6)*-pi,[],1);
    bounds.params.ajoints.x0 = reshape(ones(3,6)*0,[],1);
    
    bounds.params.pjoints.lb = [0,0];
    bounds.params.pjoints.ub = [2,2];
    bounds.params.pjoints.x0 = [0,0.5];
    
    bounds.params.pfoot.lb = [0,0,0];
    bounds.params.pfoot.ub = [0,0,0];
    bounds.params.pfoot.x0 = [0,0,0];
    
    bounds.inputs.ConstraintWrench.ffoot.x0 = [0,100,0];
    bounds.zmp.lb = -0.1;
    bounds.zmp.ub = -0.1;
    
    
    %     load('res/static_pose.mat','gait');
    load('res/gaits/static_r-0-7_th=84.mat', 'gait');
    bounds.restPos = [zeros(3,1);gait.states.x(4:end,end)];
    bounds.restVel = zeros(6,1);
    bounds.restAcc = zeros(6,1);
    %     load('res/gaits/static_r-0-7_th=84.mat', 'gait');
    bounds.initialPos = [zeros(3,1);gait.states.x(4:end,1)];
    bounds.initialVel = gait.states.dx(:,1);
    
    
    bounds.pos_weight = blkdiag(zeros(3),eye(3)*20000);
    bounds.vel_weight = blkdiag(zeros(3),eye(3)*5000);
    bounds.tor_weight = eye(3)*0.01;
    bounds.momentum_weight = 500;
    bounds.zmp_weight = 1000;
    
    bounds.push_force = [0;0];
    bounds.xcom.lb = -0.2;
    bounds.xcom.ub = -0.0;
    bounds.zcom.lb = 0.2;
    bounds.zcom.ub = 0.7;
    bounds.torso.lb = deg2rad(-50);
    bounds.torso.ub = deg2rad(50);
    
    bounds.rcom.lb = 0.3;
    bounds.rcom.ub = 0.7;
    bounds.thetacom.lb = deg2rad(72);
    bounds.thetacom.ub = deg2rad(96);
    
    %     bounds.rcom.initial = 0.7;
    %     bounds.rcom.terminal = 0.7;
    %     bounds.thetacom.initial = deg2rad(84);
    %     bounds.thetacom.terminal = deg2rad(84);
    
    
    
    
    if is_hybrid
        model_bounds = bounds;
        
        bounds = struct();
        for i=1:height(sys.Gamma.Nodes)
            if i>1
                model_bounds.time.t0.ub = 10;
            end
            
            bounds.(sys.Gamma.Nodes.Name{i}) = model_bounds;
        end
        
        for i=1:height(sys.Gamma.Edges)
            name = sys.Gamma.Edges.Guard{i}.Name;
            bounds.(name) = model_bounds;

            bounds.(name).states.xn = model_bounds.states.x;
            bounds.(name).states.dxn = model_bounds.states.dx;
        end
    end
end

