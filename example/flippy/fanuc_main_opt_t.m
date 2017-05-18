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

bounds.states.x.lb = [ -pi/2,     0, -pi/2, -pi/2, -pi/2,   0, 0];
bounds.states.x.ub = [  pi/2,  pi/2,   0,   pi/2,  pi/2,  pi, 0];
bounds.states.dx.lb = -17*ones(1,flippy.numState);
bounds.states.dx.ub = 17*ones(1,flippy.numState);
bounds.states.ddx.lb = - 1000*ones(1,flippy.numState);
bounds.states.ddx.ub = 1000*ones(1,flippy.numState);





bounds.params.avel.lb = 2*pi;
bounds.params.avel.ub = 10*pi;
bounds.params.apos.lb = -100;
bounds.params.apos.ub = 100;
bounds.params.ppos.lb = [pi, 0];
bounds.params.ppos.ub = [pi, 0];
bounds.vel.ep = 10;% y1dot = -ep*y1
bounds.pos.kp = 100; % y2ddot = -kd*y2dot - kp*y2
bounds.pos.kd = 20;


flippy.UserNlpConstraint = str2func('fanuc_constr_opt_t');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Create a gait-optimization NLP based on the existing hybrid system
%%%% model. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_grid = 10;
opts = struct(...%'ConstantTimeHorizon',nan(2,1),... %NaN - variable time, ~NaN, fixed time
    'DerivativeLevel',1,... % either 1 (only Jacobian) or 2 (both Jacobian and Hessian)
    'EqualityConstraintBoundary',0,...
    'DistributeTimeVariable',false); % non-zero positive small value will relax the equality constraints
nlp = TrajectoryOptimization('ur5opt', flippy, num_grid, bounds, opts);

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
solver.Options.ipopt.max_iter = 10000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Run the optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[sol, info] = optimize(solver);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Export the optimization result
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[tspan, states, inputs, params] = exportSolution(nlp, sol);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Plot the basic result
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xdata =zeros(1,nlp.NumNode);
ydata =zeros(1,nlp.NumNode);
zdata =zeros(1,nlp.NumNode);
for i = 1:nlp.NumNode
zdata(1,i) = endeffclearance_sca_LR(states.x(:,i));
ydata(1,i) = endeffy_sca_LR(states.x(:,1));
xdata(1,i) = endeffx_sca_LR(states.x(:,1));
end
figure(301);
plot3(xdata,ydata,zdata);grid on;
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
param{1}.name = 'FanucFlipPlaceBurger';
polydegree = flippy.VirtualConstraints.pos.PolyDegree;
num2degree = flippy.VirtualConstraints.pos.Dimension;
param{1}.a    = reshape(params.apos,num2degree,polydegree+1);
if isfield(params,{'params.ppos'}), param{1}.p    = params.ppos;
else, param{1}.p = [1, 0];end
param{1}.v    = [];
param{1}.x_plus = [states.x(:,1);states.dx(:,1)]';
param{1}.x_minus = [states.x(:,end);states.dx(:,end)]';
% param_save_file = fullfile(cur,'param','fanuc_2017_05_16_1024.yaml');
% yaml_write_file(param_save_file,param);
