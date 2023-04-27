function bounds = GetBounds(model, system, speed)
    
    
    if nargin < 3
        speed = [0, 0]; % walk in place gait
    end
    
    %% first get the model specific boundary values
    
    r_stance =system.Gamma.Nodes.Domain{1};
    l_stance = system.Gamma.Nodes.Domain{2};
    
    
    % fixed joint constraint wrench
    %     updateBound(model.Inputs.fqfixed, -10000, 10000);
    % fixed joint constraints
    %     updateBound(model.Params.pqfixed, zeros(3,1), zeros(3,1));
    
    updateBound(r_stance.Params.pRightSole, zeros(6,1), zeros(6,1));
    updateBound(r_stance.Params.aOutputs, -100, 100);
    updateBound(r_stance.Params.pOutputs, [0, 0]', [2, 2]');

    updateBound(l_stance.Params.pLeftSole, [-10, -10, 0, 0, 0, 0]', [10, 10, 0, 0, 0, 0]');
    updateBound(l_stance.Params.aOutputs, -100, 100);
    updateBound(l_stance.Params.pOutputs, [0, 0]', [2, 2]');

    updateBound(r_stance.Inputs.fRightSole, ...
        [-10000,-10000,0,-10000,-10000,-10000]',...
        [10000,10000,10000,10000,10000,10000]');

    updateBound(l_stance.Inputs.fLeftSole, ...
        [-10000,-10000,0,-10000,-10000,-10000]',...
        [10000,10000,10000,10000,10000,10000]');

    bounds = getBounds(system);


    
    
    step_duration = 0.5;
    vx = speed(1);
    vy = speed(2); 
    
    
    
    constrBounds.foot_clearance.lb = 0.06;
    constrBounds.foot_clearance.ub = 0.15;
    constrBounds.averageVelocity.lb = speed;
    constrBounds.averageVelocity.ub = speed;
    
    constrBounds.yaw_initial.lb = 0;
    constrBounds.yaw_initial.ub = 0;
    
    
    constrBounds.footVelocityBeginning.lb = [-0.2, -0.05, 0]';
    constrBounds.footVelocityBeginning.ub = [0.2, 0.05, 0.3]';
    constrBounds.footVelocityEnd.lb = [-0.1,-0.05,-0.5]';
    constrBounds.footVelocityEnd.ub = [0.4,0.05,-0.0]';
    
    
    
    
    
    %% some common boundary values are defined here
    
    bounds.RightStance.time.t0.lb = 0;
    bounds.RightStance.time.t0.ub = 0;
    bounds.RightStance.time.t0.x0 = 0;
    bounds.RightStance.time.tf.lb = step_duration;
    bounds.RightStance.time.tf.ub = step_duration;    
    bounds.RightStance.time.tf.x0 = step_duration;
    bounds.RightStance.constrBounds = constrBounds;
    
    bounds.RightStance.constrBounds.stepWidth.lb = 0.178+0.5*vy-0.01;
    bounds.RightStance.constrBounds.stepWidth.ub = 0.178+1*vy+0.01;
    bounds.RightStance.constrBounds.stepLength.ub = -vx*0.5 + 0.01;
    bounds.RightStance.constrBounds.stepLength.lb = -vx*1 - 0.01;
    
    bounds.RightStance.constrBounds.outputLimit.lb = [-0.2,-0.1,-0.2,0,0,0]';
    bounds.RightStance.constrBounds.outputLimit.ub = [0.2,0.2,0.05,0,0,0]'; 
    
    
    
    % feedback control gain for virtual constraints
    bounds.RightStance.options.enforceVirtualConstraints = true;
    bounds.RightStance.gains.kp = 100;
    bounds.RightStance.gains.kd = 20;

    bounds.RightStance.params.pOutputs.x0 = [0,0.5];
    
    


    %% Right Stance
    %%% Time Duration
    
    bounds.LeftStance.time.t0.lb = 0;
    bounds.LeftStance.time.t0.ub = 0;
    bounds.LeftStance.time.t0.x0 = 0;
    bounds.LeftStance.time.tf.lb = step_duration;
    bounds.LeftStance.time.tf.ub = step_duration;    
    bounds.LeftStance.time.tf.x0 = step_duration;
    
    bounds.LeftStance.constrBounds = constrBounds;
    bounds.LeftStance.params.pOutputs.x0 = [0,0.5];
    
    
    
    bounds.LeftStance.constrBounds.stepWidth.lb = 0.178+0.5*vy-0.01;
    bounds.LeftStance.constrBounds.stepWidth.ub = 0.178+1*vy+0.01;
    bounds.LeftStance.constrBounds.stepLength.lb = vx*0.5 - 0.01;
    bounds.LeftStance.constrBounds.stepLength.ub = vx*1 + 0.01;
    
    bounds.LeftStance.constrBounds.outputLimit.lb = [-0.2,-0.1,-0.2,0,0,0]';
    bounds.LeftStance.constrBounds.outputLimit.ub = [0.2,0.2,0.05,0,0,0]'; 
    
    
    bounds.LeftStance.options.enforceVirtualConstraints = false;
    bounds.LeftStance.gains.kp = 100;
    bounds.LeftStance.gains.kd = 20;
    


    
end
