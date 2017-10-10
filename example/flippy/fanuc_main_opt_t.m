%% The main script to run the ATLAS multi-contact walking optimization
% 
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% FLIPPY robot model object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main_sim
% pick the optmization type and the initial guess parameters
load_initial_guess = 0;
traj_type = 1; % 1 = translate 2 = scoop 3 = pickup 4 = drop 5 = joint to joint
switch(traj_type)
    case 1
        initial_guess_file = [cur,'/param/fanuc_6DOF_trans_guess_15nodes.yaml'];
        fanuc_constr_opt_str = 'fanuc_constr_opt_trans_t';
    case 2
        initial_guess_file = [cur,'/param/fanuc_6DOF_guess_pickup_2017_09_07_1655.yaml'];
        fanuc_constr_opt_str = 'fanuc_constr_opt_scoop_t';
    case 3
        initial_guess_file = [cur,'/param/fanuc_6DOF_guess_pickup_2017_09_07_1655.yaml'];
        fanuc_constr_opt_str = 'fanuc_constr_opt_pickup_t';
    case 4
        initial_guess_file = [cur,'/param/fanuc_6DOF_guess_flip_2017_09_07_1449.yaml'];
        fanuc_constr_opt_str = 'fanuc_constr_opt_drop_t';
    case 5
        initial_guess_file = [cur,'/param/fanuc_6DOF_guess_flip_2017_09_07_1449.yaml'];
        fanuc_constr_opt_str = 'fanuc_constr_opt_j2j_t';
end
%%
%!!!! update the limit of joint angles/velocity/acceleration
bounds = flippy.getLimits();


% time duration
%@note for fixed time duration, try use the optional
%'ConstantTimeHorizon=[0,T]', where T is the fixed time duration
bounds.time.t0.lb = 0; % starting time
bounds.time.t0.ub = 0;
bounds.time.tf.lb = 1.0; % terminating time
bounds.time.tf.ub = 5.0;
bounds.time.duration.lb = 1.0; % duration (optional)
bounds.time.duration.ub = 5.0;

bounds.states.x.lb = [ -pi/2,   -pi/2,  -1,  -pi, -2,   - pi ]; % -1.09 for joint 3 is the minimum limit
bounds.states.x.ub = [  2.8,  2*pi/3,   pi/2,   pi, 2,    pi ];
bounds.states.dx.lb = -16*ones(1,flippy.numState);
bounds.states.dx.ub =  16*ones(1,flippy.numState);
bounds.states.ddx.lb = -800*ones(1,flippy.numState);
bounds.states.ddx.ub =  800*ones(1,flippy.numState);

bounds.inputs.Control.u.lb = - ones(1,flippy.numState)*Inf;
bounds.inputs.Control.u.ub = ones(1,flippy.numState)*Inf;


bounds.params.apos.lb = -600;
bounds.params.apos.ub = 600;
% bounds.vel.ep = 10;% y1dot = -ep*y1
bounds.pos.kp = 10; % y2ddot = -kd*y2dot - kp*y2
bounds.pos.kd = 2;


flippy.UserNlpConstraint = str2func(fanuc_constr_opt_str);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Create a gait-optimization NLP based on the existing hybrid system
%%%% model. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_grid = 15;
opts = struct(...%'ConstantTimeHorizon',nan(2,1),... %NaN - variable time, ~NaN, fixed time
    'DerivativeLevel',1,... % either 1 (only Jacobian) or 2 (both Jacobian and Hessian)
    'EqualityConstraintBoundary',0,...
    'DistributeTimeVariable',false); % non-zero positive small value will relax the equality constraints
nlp = TrajectoryOptimization('fanucopt', flippy, num_grid, bounds, opts);

flippy_cost_opt(nlp, bounds);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Compile and export optimization functions
%%%% (uncomment the following lines when run it for the first time.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nlp.update;
% exclude = {'dynamics_equation'};
% % exclude = [];
% compileConstraint(nlp,[],export_path,exclude);
% compileObjective(nlp,[],export_path);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Link the NLP problem to a NLP solver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
solver = IpoptApplication(nlp);
solver.Options.ipopt.max_iter = 1000;
solver.Options.ipopt.tol = 1e-3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Run the optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if load_initial_guess
    [params,x0] = loadParam(initial_guess_file);
    [sol, info] = optimize(solver, params.sol);
else
    [sol, info] = optimize(solver);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Export the optimization result
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[tspan, states, inputs, params] = exportSolution(nlp, sol);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Plot the basic result
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flow.t = tspan;
flow.states = states;
Analyze(flow);

%% Verification of accuracy end effector position is done here
% q_init = [ -4.50629128e-03,   7.27350040e-01,  -5.79880967e-01,  -5.52882072e-03, ...
%     7.83635477e-01,   4.03088942e-01];
% q_final = [ -3.59767937e-02,   8.80253698e-01,  -6.17720449e-01, ...
% -1.11309055e-01, 1.52223527e+00,   3.41841957e+00];
% disp('z')
% disp(endeffz_sca_LR(q_init))
% disp(endeffz_sca_LR(q_final))
% disp('y')
% disp(endeffy_sca_LR(q_init))
% disp(endeffy_sca_LR(q_final))
% disp('x')
% disp(endeffx_sca_LR(q_init))
% disp(endeffx_sca_LR(q_final))
% q_zero = zeros(1,6);
% positionforqzero = [endeffz_sca_LR(q_zero),
%                     endeffy_sca_LR(q_zero),
%                     endeffx_sca_LR(q_zero)]
% orientationforqinit = [o_endeffx_LR(q_init),
%                        o_endeffy_LR(q_init),
%                        o_endeffz_LR(q_init)]
% orientationforqfinal = [o_endeffx_LR(q_final),
%                        o_endeffy_LR(q_final),
%                        o_endeffz_LR(q_final)]
% orientationforqzero = [o_endeffx_LR(q_zero),
%                        o_endeffy_LR(q_zero),
%                        o_endeffz_LR(q_zero)]

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Run animation of the optimal trajectory
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% export_file = fullfile(cur,'tmp','flippy_move.avi');
% anim = animator(flippy);
% anim.Options.ViewAngle=[39,24];
% anim.animate(calcs,export_file)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Save param in a yaml file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
param = cell(1,1);
param{1}.name = 'FanucFlipBurger';
polydegree = flippy.VirtualConstraints.pos.PolyDegree;
num2degree = flippy.VirtualConstraints.pos.Dimension;
param{1}.a    = reshape(params.apos,num2degree,polydegree+1);
if isfield(params,{'params.ppos'}), param{1}.p    = params.ppos;
else, param{1}.p = [tspan(end), tspan(1)];end
param{1}.v    = [];
param{1}.x_plus = [states.x(:,1);states.dx(:,1)]';
param{1}.x_minus = [states.x(:,end);states.dx(:,end)]';
param{1}.sol = sol;
param_save_file = fullfile(cur,'param','fanuc_6DOF_2017_09_07_1655.yaml');
yaml_write_file(param_save_file,param);

writecsvfilebezier(param{1}.p(1),param{1}.a);
