%% The main script to run the ATLAS flat-footedwalking simulation
% 
%
%% model & simulation
% symmetric_one_step_sim;
%% bound
model_bounds = atlas.getLimits();
bounds = struct();
bounds.RightStance = model_bounds;

bounds.RightStance.time.t0.lb = 0;
bounds.RightStance.time.t0.ub = 0;
bounds.RightStance.time.tf.lb = 0.2;
bounds.RightStance.time.tf.ub = 1;
bounds.RightStance.time.duration.lb = 0.2;
bounds.RightStance.time.duration.ub = 1;
bounds.RightStance.inputs.ConstraintWrench.fqfixed.lb = -10000;
bounds.RightStance.inputs.ConstraintWrench.fqfixed.ub = 10000;
bounds.RightStance.inputs.ConstraintWrench.fRightSole.lb = -10000;
bounds.RightStance.inputs.ConstraintWrench.fRightSole.ub = 10000;

bounds.RightStance.params.pqfixed.lb = zeros(3,1);
bounds.RightStance.params.pqfixed.ub = zeros(3,1);
bounds.RightStance.params.pRightSole.lb = zeros(6,1);
bounds.RightStance.params.pRightSole.ub = zeros(6,1);
bounds.RightStance.params.avelocity.lb = 0.2;
bounds.RightStance.params.avelocity.ub = 0.6;
bounds.RightStance.params.pvelocity.lb = [0.05, -0.3];
bounds.RightStance.params.pvelocity.ub = [0.3, -0.1];
bounds.RightStance.params.aposition.lb = -100;
bounds.RightStance.params.aposition.ub = 100;
bounds.RightStance.params.pposition.lb = [0.05, -0.3];
bounds.RightStance.params.pposition.ub = [0.3, -0.1];
bounds.RightStance.velocity.ep = 10;
bounds.RightStance.position.kp = 100;
bounds.RightStance.position.kd = 20;



%% problem
r_stance.UserNlpConstraint = str2func('right_stance_constraints');
l_impact.UserNlpConstraint = str2func('left_impact_constraints');
num_grid.RightStance = 10;
nlp = HybridTrajectoryOptimization('AtlasFlat',atlas_flat,num_grid,'EqualityConstraintBoundary',1e-4);
nlp.configure(bounds);

% remove constraint wrench constraints
% removeConstraint(nlp.Phase(1),'u_friction_cone_RightSole');
% removeConstraint(nlp.Phase(1),'u_zmp_RightSole');
%% cost
u = r_stance.Inputs.Control.u;
u2r = tovector(norm(u).^2);
u2r_fun = SymFunction(['torque_' r_stance.Name],u2r,{u});
rs_phase = getPhaseIndex(nlp,'RightStance');
addRunningCost(nlp.Phase(rs_phase),u2r_fun,'u');

%% compile MEX
% compileConstraint(nlp,[],[],export_path);
% compileObjective(nlp,[],[],export_path);

%% initial guess
loadNodeInitialGuess(nlp.Phase(1),r_stance, r_stance_param);
loadEdgeInitialGuess(nlp.Phase(2),r_stance, r_stance);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Link the NLP problem to a NLP solver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
solver = IpoptApplication(nlp);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Run the optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
solver.initialize();
[sol, info] = optimize(solver);
