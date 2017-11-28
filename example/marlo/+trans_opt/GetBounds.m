function bounds = GetBounds(model, vel_lb, vel_ub, T, x0, xf)
    
    
    if nargin < 2
        vel_lb = [0.0,0];
        vel_ub = [0.0,0];
    end
    
    if nargin < 4
        T = 0.4;
    end
    
    if nargin < 5
        x0 = zeros(model.numState*2,1);
    end
    
    if nargin < 6
        xf = zeros(model.numState*2,1);
    end
    
    %% first get the model specific boundary values
    model_bounds = model.getLimits(); % x, dx, ddx, u
    
    
    
    model_bounds.options.enforceVirtualConstraints = true;
    
    % fixed joint constraint wrench
    model_bounds.inputs.ConstraintWrench.ffourBar.lb = -1000;
    model_bounds.inputs.ConstraintWrench.ffourBar.ub = 1000;
    
    % fixed joint constraints
    model_bounds.params.pfourBar.lb = zeros(4,1);
    model_bounds.params.pfourBar.ub = zeros(4,1);


    model_bounds.constrBounds.yaw_initial.lb = 0;
    model_bounds.constrBounds.yaw_initial.ub = 0;
    
    
    
    % feedback control gain for virtual constraints
    model_bounds.gains.kp = 100;
    model_bounds.gains.kd = 20;
    
    
    %%% Constraint bounds
    %     vel = [0.0, -0.8].';
    %     T   = 0.4;
    
    %%% Step Duration
    model_bounds.time.duration.lb = T;
    model_bounds.time.duration.ub = T;
    
    model_bounds.time.t0.lb = 0;
    model_bounds.time.t0.ub = 0;
    model_bounds.time.t0.x0 = 0;
    model_bounds.time.tf.lb = 0;
    model_bounds.time.tf.ub = T;
    model_bounds.time.tf.x0 = T;
    
    model_bounds.constrBounds.foot_clearance_1.lb = 0.03;
    model_bounds.constrBounds.foot_clearance_1.ub = 0.3;
    model_bounds.constrBounds.foot_clearance_2.lb = 0.15;
    model_bounds.constrBounds.foot_clearance_2.ub = 0.3;
    model_bounds.constrBounds.foot_clearance_3.lb = 0.05;
    model_bounds.constrBounds.foot_clearance_3.ub = 0.3;
    model_bounds.constrBounds.averageVelocity.lb = vel_lb;
    model_bounds.constrBounds.averageVelocity.ub = vel_ub;
    
    %     model_bounds.states.x.lb(1:2) = vel_lb;
    %     model_bounds.states.x.ub(1:2) = vel_ub;
    
    %     model_bounds.constrBounds.stepLength.lb = vel(1)*T;
    %     model_bounds.constrBounds.stepLength.ub = vel(1)*T;
    %
    %     model_bounds.constrBounds.stepWidth.lb = vel(1)*T;
    %     model_bounds.constrBounds.stepWidth.ub = vel(1)*T;
    
    model_bounds.constrBounds.footVelocityBeginning.lb = [-0.15, -0.15, 0]';
    model_bounds.constrBounds.footVelocityBeginning.ub = [0.15, 0.15, 0.3]';
    model_bounds.constrBounds.footVelocityEnd.lb = [-0.15, -0.15, -0.25]';
    model_bounds.constrBounds.footVelocityEnd.ub = [0.15, 0.15, -0.05]';
    
    
    
    %%% Common Virtual Constraints
    model_bounds.params.aoutput.lb = -2*pi;
    model_bounds.params.aoutput.ub = 2*pi;
    
    model_bounds.params.poutput.lb = [0, 0];
    model_bounds.params.poutput.ub = [0, T];
    model_bounds.params.poutput.x0 = [0, T];
    
    model_bounds.params.pRightFoot.lb = [-10, -10, 0, 0];
    model_bounds.params.pRightFoot.ub = [10, 10, 0, 0];
    
    model_bounds.params.pLeftFoot.lb = [-10, -10, 0, 0];
    model_bounds.params.pLeftFoot.ub = [10, 10, 0, 0];
    
    
    model_bounds.inputs.ConstraintWrench.fRightFoot.lb = [-1000,-1000,300,-1000]';
    model_bounds.inputs.ConstraintWrench.fRightFoot.ub = [1000,1000,1000,1000]';
    
    model_bounds.inputs.ConstraintWrench.fLeftFoot.lb = [-1000,-1000,300,-1000]';
    model_bounds.inputs.ConstraintWrench.fLeftFoot.ub = [1000,1000,1000,1000]';
    
    
    
    
    
    %% construct the boundary values for each domain 
    bounds = struct();
    
    wt = 0.3662;
    vx_lb = vel_lb(1);
    vy_lb = vel_lb(2);
    vx_ub = vel_ub(1);
    vy_ub = vel_ub(2);
    
    %%
    bounds.RightStance1 = model_bounds;
    bounds.RightStance1.constrBounds.knee.lb = [deg2rad(50),deg2rad(50)];
    bounds.RightStance1.constrBounds.knee.ub = [deg2rad(60),deg2rad(150)];
    
    bounds.RightStance1.constrBounds.stepWidth.lb = -wt - vx_ub*T;
    bounds.RightStance1.constrBounds.stepWidth.ub = -wt - vx_lb*T;
    
    bounds.RightStance1.constrBounds.stepLength.lb = -vy_ub*T;
    bounds.RightStance1.constrBounds.stepLength.ub = -vy_lb*T;
    
    
    bounds.RightStance1.constrBounds.full_state.lb = x0;
    bounds.RightStance1.constrBounds.full_state.ub = x0;
    idx = [3:9, 12:14, 19:25, 28:30]; 
    bounds.RightStance1.constrBounds.actuated_state.lb = x0(idx);
    bounds.RightStance1.constrBounds.actuated_state.ub = x0(idx);
    %%
    bounds.LeftImpact.states.x = model_bounds.states.x;
    bounds.LeftImpact.states.xn = model_bounds.states.x;
    bounds.LeftImpact.states.dx = model_bounds.states.dx;
    bounds.LeftImpact.states.dxn = model_bounds.states.dx;
    
    bounds.LeftImpact.inputs = struct();
    bounds.LeftImpact.inputs.ConstraintWrench.ffourBar.lb = -20;
    bounds.LeftImpact.inputs.ConstraintWrench.ffourBar.ub = 20;
    bounds.LeftImpact.inputs.ConstraintWrench.fLeftFoot.lb = [-20,-20,0,-10]';
    bounds.LeftImpact.inputs.ConstraintWrench.fLeftFoot.ub = [20,20,150,10]';
    bounds.LeftImpact.params = struct();


    %% Right Stance
    bounds.LeftStance1 = model_bounds;
    
    bounds.LeftStance1.constrBounds.knee.lb = [deg2rad(50),deg2rad(50)];
    bounds.LeftStance1.constrBounds.knee.ub = [deg2rad(150),deg2rad(60)];
    
    bounds.LeftStance1.midState_QFit = zeros(6,3);
    bounds.LeftStance1.midState_dQFit = zeros(6,3);
    
    bounds.LeftStance1.constrBounds.stepWidth.lb = -wt + vx_lb*T;
    bounds.LeftStance1.constrBounds.stepWidth.ub = -wt + vx_ub*T;
    
    bounds.LeftStance1.constrBounds.stepLength.lb = vy_lb*T;
    bounds.LeftStance1.constrBounds.stepLength.ub = vy_ub*T;
    
    
    %%
    bounds.RightImpact.states.x = model_bounds.states.x;
    bounds.RightImpact.states.xn = model_bounds.states.x;
    bounds.RightImpact.states.dx = model_bounds.states.dx;
    bounds.RightImpact.states.dxn = model_bounds.states.dx;
    bounds.RightImpact.inputs = struct();
    bounds.RightImpact.inputs.ConstraintWrench.ffourBar.lb = -20;
    bounds.RightImpact.inputs.ConstraintWrench.ffourBar.ub = 20;
    bounds.RightImpact.inputs.ConstraintWrench.fRightFoot.lb = [-20,-20,0,-10]'';
    bounds.RightImpact.inputs.ConstraintWrench.fRightFoot.ub = [20,20,150,10]';
    bounds.RightImpact.params = struct();

    
    %% 
    bounds.RightStance2 = bounds.RightStance1;
    
    bounds.RightStance2.midState_QFit = zeros(6,3);
    bounds.RightStance2.midState_dQFit = zeros(6,3);
    
    
    bounds.LeftStance2  = bounds.LeftStance1;
    
    bounds.LeftStance2.constrBounds.full_state.lb = xf;
    bounds.LeftStance2.constrBounds.full_state.ub = xf;
    
    bounds.LeftStance2.constrBounds.actuated_state.lb = xf(idx);
    bounds.LeftStance2.constrBounds.actuated_state.ub = xf(idx);
end
