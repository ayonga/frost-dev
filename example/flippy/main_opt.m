%% The main script to run the ATLAS multi-contact walking optimization
% 
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% FLIPPY robot model object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main_sim

%!!!! update the limit of joint angles/velocity/acceleration
bounds = flippy.getLimits();


% time duration
%@note for fixed time duration, try use the optional
%'ConstantTimeHorizon=[0,T]', where T is the fixed time duration
bounds.time.t0.lb = 0; % starting time
bounds.time.t0.ub = 0;
bounds.time.tf.lb = 0.2; % terminating time
bounds.time.tf.ub = 1;
bounds.time.duration.lb = 0.2; % duration (optional)
bounds.time.duration.ub = 1;

bounds.states.x.lb = [ -pi, -pi, 0, -pi, -pi, -pi]';
bounds.states.x.ub = [pi,  pi, pi, pi, pi, pi];
bounds.states.dx.lb = -17*ones(6,1);
bounds.states.dx.ub = 17*ones(6,1);
bounds.states.ddx.lb = - [1000,1000,1000,1000,1000,1000];
bounds.states.ddx.ub = [1000,1000,1000,1000,1000,1000];





bounds.params.avel.lb = 4*pi;
bounds.params.avel.ub = 4*pi;
bounds.params.pvel.lb = [pi, 0];
bounds.params.pvel.ub = [pi, 0];
bounds.params.apos.lb = -100;
bounds.params.apos.ub = 100;
bounds.params.ppos.lb = [0, pi];
bounds.params.ppos.ub = [0, pi];
bounds.vel.ep = 10;% y1dot = -ep*y1
bounds.pos.kp = 100; % y2ddot = -kd*y2dot - kp*y2
bounds.pos.kd = 20;


flippy.UserNlpConstraint = str2func('flippy_constr_opt');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Create a gait-optimization NLP based on the existing hybrid system
%%%% model. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_grid = 10;
opts = struct(...%'ConstantTimeHorizon',nan(2,1),... %NaN - variable time, ~NaN, fixed time
    'DerivativeLevel',1,... % either 1 (only Jacobian) or 2 (both Jacobian and Hessian)
    'EqualityConstraintBoundary',0); % non-zero positive small value will relax the equality constraints
nlp = TrajectoryOptimization('ur5opt', flippy, num_grid, bounds, opts);

flippy_cost_opt(nlp, bounds);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Compile and export optimization functions
%%%% (uncomment the following lines when run it for the first time.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nlp.update;
% % exclude = {'dynamics_equation'};
% exclude = [];
% compileConstraint(nlp,[],export_path,exclude);
% compileObjective(nlp,[],export_path);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Link the NLP problem to a NLP solver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
solver = IpoptApplication(nlp);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Run the optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[sol, info] = optimize(solver);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Export the optimization result
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[tspan, states, inputs, params] = exportSolution(nlp, sol);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Run animation of the optimal trajectory
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% export_file = fullfile(cur,'tmp','flippy_move.avi');
% anim = animator(flippy);
% anim.Options.ViewAngle=[39,24];
% anim.animate(calcs,export_file)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Save param in a yaml file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% param_save_file = fullfile(cur,'param','flippy_move_2017_05_03_1005.yaml');
% yaml_write_file(param_save_file,param);
