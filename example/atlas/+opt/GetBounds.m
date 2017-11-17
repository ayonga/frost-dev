function bounds = GetBounds(model, speed)
    
    
    if nargin < 2
        speed = [0, 0]; % walk in place gait
    end
    
    %% first get the model specific boundary values
    model_bounds = model.getLimits(); % x, dx, ddx, u
    
    
    
    model_bounds.options.enforceVirtualConstraints = true;
    
    % fixed joint constraint wrench
    model_bounds.inputs.ConstraintWrench.fqfixed.lb = -10000;
    model_bounds.inputs.ConstraintWrench.fqfixed.ub = 10000;
    
    % fixed joint constraints
    model_bounds.params.pqfixed.lb = zeros(3,1);
    model_bounds.params.pqfixed.ub = zeros(3,1);
    
    % feedback control gain for virtual constraints
    model_bounds.gains.kp = 100;
    model_bounds.gains.kd = 20;
    
    
    %%% Step Duration
    model_bounds.time.duration.lb = 0.5;
    model_bounds.time.duration.ub = 1;
    
    model_bounds.time.t0.lb = 0;
    model_bounds.time.t0.ub = 2;
    model_bounds.time.tf.lb = 0;
    model_bounds.time.tf.ub = 2;
    
    
    model_bounds.constrBounds.foot_clearance.lb = 0.06;
    model_bounds.constrBounds.foot_clearance.ub = 0.15;
    model_bounds.constrBounds.averageVelocity.lb = speed;
    model_bounds.constrBounds.averageVelocity.ub = speed;
    
    model_bounds.constrBounds.yaw_initial.lb = 0;
    model_bounds.constrBounds.yaw_initial.ub = 0;
    
    
    model_bounds.constrBounds.footVelocityBeginning.lb = [-0.2, -0.05, 0]';
    model_bounds.constrBounds.footVelocityBeginning.ub = [0.2, 0.05, 0.3]';
    model_bounds.constrBounds.footVelocityEnd.lb = [-0.1,-0.05,-0.5]';
    model_bounds.constrBounds.footVelocityEnd.ub = [0.4,0.05,-0.0]';
    
    
    
    %%% Common Virtual Constraints
    model_bounds.params.aposition.lb = -100; % bezier coefficient for virtual constraints "position"
    model_bounds.params.aposition.ub = 100;
    model_bounds.params.pposition.lb = [0, 0]; % phase paramaters for virtual constraints "position"
    model_bounds.params.pposition.ub = [2, 2];
    model_bounds.params.pRightSole.lb = [0, 0, 0, 0, 0, 0];
    model_bounds.params.pRightSole.ub = [0, 0, 0, 0, 0, 0];
    
    model_bounds.params.pLeftSole.lb = [-10, -10, 0, 0, 0, 0];
    model_bounds.params.pLeftSole.ub = [10, 10, 0, 0, 0, 0];
    
    
    
    %% construct the boundary values for each domain 
    bounds = struct();
    
    vx = speed(1);
    vy = speed(2); 
    
    bounds.RightStance = model_bounds;
    %% some common boundary values are defined here
    
    bounds.RightStance.time.t0.lb = 0;
    bounds.RightStance.time.t0.ub = 0;
    bounds.RightStance.time.t0.x0 = 0;
    bounds.RightStance.time.tf.x0 = 0.5;
    
    bounds.RightStance.inputs.ConstraintWrench.fRightSole.lb = [-10000,-10000,0,-10000,-10000,-10000]';
    bounds.RightStance.inputs.ConstraintWrench.fRightSole.ub = [10000,10000,10000,10000,10000,10000]';
    
    bounds.RightStance.constrBounds.stepWidth.lb = 0.178+0.5*vy-0.01;
    bounds.RightStance.constrBounds.stepWidth.ub = 0.178+1*vy+0.01;
    bounds.RightStance.constrBounds.stepLength.ub = -vx*0.5 + 0.01;
    bounds.RightStance.constrBounds.stepLength.lb = -vx*1 - 0.01;
    
    bounds.RightStance.constrBounds.outputLimit.lb = [-0.2,-0.1,-0.2,0,0,0]';
    bounds.RightStance.constrBounds.outputLimit.ub = [0.2,0.2,0.05,0,0,0]'; 
    
    
    bounds.RightStance.params.pposition.x0 = [0,0.5];
    
    bounds.LeftImpact.states.x = model_bounds.states.x;
    bounds.LeftImpact.states.xn = model_bounds.states.x;
    bounds.LeftImpact.states.dx = model_bounds.states.dx;
    bounds.LeftImpact.states.dxn = model_bounds.states.dx;
    
    bounds.LeftImpact.inputs = struct();
    bounds.LeftImpact.inputs.ConstraintWrench.fqfixed.lb = -10000;
    bounds.LeftImpact.inputs.ConstraintWrench.fqfixed.ub = 10000;
    bounds.LeftImpact.inputs.ConstraintWrench.fLeftSole.lb = [-10000,-10000,0,-10000,-10000,-10000]';
    bounds.LeftImpact.inputs.ConstraintWrench.fLeftSole.ub = [10000,10000,10000,10000,10000,10000]';

    
    
    bounds.LeftImpact.params = struct();


    %% Right Stance
    bounds.LeftStance = model_bounds;
    %%% Time Duration
    
    bounds.LeftStance.time.t0.lb = 0;
    bounds.LeftStance.time.t0.ub = 0;
    bounds.LeftStance.time.t0.x0 = 0;
    bounds.LeftStance.time.tf.x0 = 0.5;
    
    bounds.LeftStance.params.pposition.x0 = [0,0.5];
    
    bounds.LeftStance.inputs.ConstraintWrench.fLeftSole.lb = [-10000,-10000,0,-10000, -10000, -10000]';
    bounds.LeftStance.inputs.ConstraintWrench.fLeftSole.ub = [10000,10000,10000,10000,10000,10000]';
    
    
    bounds.LeftStance.constrBounds.stepWidth.lb = 0.178+0.5*vy-0.01;
    bounds.LeftStance.constrBounds.stepWidth.ub = 0.178+1*vy+0.01;
    bounds.LeftStance.constrBounds.stepLength.lb = vx*0.5 - 0.01;
    bounds.LeftStance.constrBounds.stepLength.ub = vx*1 + 0.01;
    
    bounds.LeftStance.constrBounds.outputLimit.lb = [-0.2,-0.1,-0.2,0,0,0]';
    bounds.LeftStance.constrBounds.outputLimit.ub = [0.2,0.2,0.05,0,0,0]'; 
    
    
    bounds.RightImpact.states.x = model_bounds.states.x;
    bounds.RightImpact.states.xn = model_bounds.states.x;
    bounds.RightImpact.states.dx = model_bounds.states.dx;
    bounds.RightImpact.states.dxn = model_bounds.states.dx;
    bounds.RightImpact.inputs = struct();
    bounds.RightImpact.inputs.ConstraintWrench.fqfixed.lb = -10000;
    bounds.RightImpact.inputs.ConstraintWrench.fqfixed.ub = 10000;
    bounds.RightImpact.inputs.ConstraintWrench.fRightSole.lb = [-10000,-10000,0,-10000,-10000,-10000]';
    bounds.RightImpact.inputs.ConstraintWrench.fRightSole.ub = [10000,10000,10000,10000,10000,10000]';
    
    
    bounds.RightImpact.params = struct();



    
end
