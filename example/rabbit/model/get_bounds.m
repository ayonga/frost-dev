function bounds = get_bounds(r_stance,l_impact)
%GET_BOUNDS Summary of this function goes here
%   Detailed explanation goes here
bounds.RightStance = getBounds(r_stance);
bounds.LeftImpact = getBounds(l_impact);

bounds.RightStance.time.t0.lb = 0;
bounds.RightStance.time.t0.ub = 0;
bounds.RightStance.time.t0.x0 = 0;
bounds.RightStance.time.tf.lb = 0.25;
bounds.RightStance.time.tf.ub = 0.75;
bounds.RightStance.time.tf.x0 = 0.75;

bounds.RightStance.states.x.lb = [-10, 0.5, -1, 2, 0.5, 2, 0.5];
bounds.RightStance.states.x.ub = [10, 2, 1, 5, 2, 5, 2];
bounds.RightStance.states.dx.lb = -20*ones(1,7);
bounds.RightStance.states.dx.ub = 20*ones(1,7);
bounds.RightStance.states.ddx.lb = -100*ones(1,7);
bounds.RightStance.states.ddx.ub = 100*ones(1,7);

bounds.RightStance.inputs.fRightToe.lb = -1000;
bounds.RightStance.inputs.fRightToe.ub = 1000;
bounds.RightStance.inputs.fRightToe.x0 = 100;

bounds.RightStance.inputs.torque.lb = -100*ones(4,1);
bounds.RightStance.inputs.torque.ub = 100*ones(4,1);
bounds.RightStance.inputs.torque.x0 = zeros(4,1);

bounds.RightStance.params.pRightToe.lb = -0*ones(3,1);
bounds.RightStance.params.pRightToe.ub = 0*ones(3,1);
bounds.RightStance.params.pRightToe.x0 = zeros(3,1);


bounds.LeftImpact.states.x.lb = [-10, 0.5, -1, 2, 0.5, 2, 0.5];
bounds.LeftImpact.states.x.ub = [10, 2, 1, 5, 2, 5, 2];
bounds.LeftImpact.states.dx.lb = -20*ones(1,7);
bounds.LeftImpact.states.dx.ub = 20*ones(1,7);
bounds.LeftImpact.states.xn.lb = [-10, 0.5, -1, 2, 0.5, 2, 0.5];
bounds.LeftImpact.states.xn.ub = [10, 2, 1, 5, 2, 5, 2];
bounds.LeftImpact.states.dxn.lb = -20*ones(1,7);
bounds.LeftImpact.states.dxn.ub = 20*ones(1,7);

bounds.LeftImpact.inputs.fRightToe.lb = -1000;
bounds.LeftImpact.inputs.fRightToe.ub = 1000;
bounds.LeftImpact.inputs.fRightToe.x0 = 100;
end

