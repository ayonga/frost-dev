%% Setup
clear; clc;
cur = pwd;
addpath(genpath(cur));

addpath('../../');
frost_addpath;
export_path = fullfile(cur, 'gen/');
% if load_path is empty, it will not load any expression.
% if non-empty and assigned valid directory, then symbolic expressions will
% be loaded  from the MX binary files from the given directory.
load_path = [];%fullfile(cur, 'gen/sym');
delay_set = false;
COMPILE = false;

% Load model
rabbit = RABBIT('urdf/five_link_walker.urdf');
if isempty(load_path)
    rabbit.configureDynamics('DelayCoriolisSet',delay_set);
else
    % load symbolic expression for the dynamics equations
    rabbit.loadDynamics(load_path, delay_set);
end

%%
% Define domains
r_stance = RightStance(rabbit, load_path);
% l_stance = LeftStance(rabbit, load_path);
r_impact = RightImpact(r_stance, load_path);
% l_impact = LeftImpact(l_stance, load_path);

% Define hybrid system
rabbit_1step = HybridSystem('Rabbit_1step');
rabbit_1step = addVertex(rabbit_1step, 'RightStance', 'Domain', r_stance);

srcs = {'RightStance'};
tars = {'RightStance'};

rabbit_1step = addEdge(rabbit_1step, srcs, tars);
rabbit_1step = setEdgeProperties(rabbit_1step, srcs, tars, ...
    'Guard', {r_impact});

%% Define User Constraints
r_stance.UserNlpConstraint = str2func('right_stance_constraints');
r_impact.UserNlpConstraint = str2func('right_impact_constraints');

%% Define User Costs
u = r_stance.Inputs.Control.u;
u2r = tovector(norm(u).^2);
u2r_fun = SymFunction(['torque_' r_stance.Name],u2r,{u});

%% Create optimization problem
num_grid.RightStance = 10;
num_grid.LeftStance = 10;
nlp = HybridTrajectoryOptimization('Rabbit_1step',rabbit_1step,num_grid,[],'EqualityConstraintBoundary',1e-4);

% Configure bounds 
setBounds;

% load some optimization related expressions here
if ~isempty(load_path)
    nlp.configure(bounds, 'LoadPath',load_path);
else
    nlp.configure(bounds);
end

 
% Add costs
addRunningCost(nlp.Phase(getPhaseIndex(nlp,'RightStance')),u2r_fun,'u');

% Changing Periodicity


    
% the configuration only depends on the relabeling matrix
removeConstraint(nlp.Phase(2), 'xPlusCont');
removeConstraint(nlp.Phase(2), 'dxPlusCont');

R = eye(7);
R([4, 5, 6, 7], :) = R([6, 7, 4, 5], :);
x = nlp.Phase(2).Plant.States.x;
xn = nlp.Phase(2).Plant.States.xn;
x_diff = R*x-xn;

symFunc = SymFunction(['xPlusCont', nlp.Phase(2).Name], x_diff(3:end), {x, xn});
nlpFunc = NlpFunction('Name', symFunc.Name, ...
    'Dimension', 5, ...
    'lb', 0,...
    'ub', 0,...
    'Type', 'Nonlinear', ...
    'SymFun', symFunc, ...
    'DepVariables', [nlp.Phase(2).OptVarTable.xn(1); nlp.Phase(1).OptVarTable.x(1)]);
addConstraint(nlp.Phase(2), nlpFunc(1).Name, 'first', nlpFunc);

symFunc = SymFunction(['dxPlusCont', nlp.Phase(2).Name], x_diff(3:end), {x, xn});
nlpFunc = NlpFunction('Name', symFunc.Name, ...
    'Dimension', 5, ...
    'lb', 0,...
    'ub', 0,...
    'Type', 'Nonlinear', ...
    'SymFun', symFunc, ...
    'DepVariables', [nlp.Phase(2).OptVarTable.dxn(1); nlp.Phase(1).OptVarTable.dx(1)]);
addConstraint(nlp.Phase(2), nlpFunc(1).Name, 'first', nlpFunc);

% Update
nlp.update;

for i = 1:(nlp.Phase(1).NumNode-1)
    nlp.Phase(1).ConstrTable.u_leftFootHeight_RightStance(i).setBoundary(-0.1, Inf);
end
nlp.Phase(1).ConstrTable.u_leftFootHeight_RightStance(end).setBoundary(0.05, 0.05);

nlp.update;

% save expressions after you run the optimization. It will save all required
% expressions
% do not need to save expressions if the model configuration is not
% changed. Adding custom constraints does not require saving any
% expressions.
% load_path = fullfile(cur, 'gen/sym');
% rabbit_1step.saveExpression(load_path);
%% Compile
if COMPILE
    if ~exist([export_path, 'opt/'])
        mkdir([export_path, 'opt/'])
    end
    rabbit.ExportKinematics([export_path,'kinematics/']);
    compileConstraint(nlp,[],[],[export_path, 'opt/']);
    compileObjective(nlp,[],[],[export_path, 'opt/']);
end

% Example constraint removal
% removeConstraint(nlp.Phase(1),'u_friction_cone_RightToe');
%%
% param=load(fullfile('C:\Users\mungam\Documents\GitHub\mpc_fiveLink\trajectories\walking\walkingRabbitGait_11-Nov-2019-19-57-37-0500_Rabbit.mat'));

%% Create Ipopt solver 
addpath(genpath(export_path));
nlp.update;
solver = IpoptApplication(nlp);
solver.Options.ipopt.max_iter = 5000; 
% solver.Options.ipopt.tol = 5e-1;
% solver.Options.ipopt.compl_inf_tol = 5e+4;
% solver.Options.ipopt.constr_viol_tol = 5e-4;
% solver.Options.ipopt.dual_inf_tol = 1e+4 ;
% Run Optimization
tic
% old = load('x0');
% [sol, info] = optimize(solver, old.sol);

[sol, info] = optimize(solver);
toc
[tspan, states, inputs, params] = exportSolution(nlp, sol);
gait = struct(...
    'tspan',tspan,...
    'states',states,...
    'inputs',inputs,...
    'params',params);
%%
checkConstraints(nlp, sol, 1e-3, 'constraintCheck.txt');
checkVariables(nlp, sol, 1e-1, 'variableCheck.txt');
open('constraintCheck.txt')
open('variableCheck.txt')
%% Animation
q_log_R = states{1}.x; % Right stance
q_log_L = q_log_R([1:3,6:7,4:5],:); % symmetric Left stance
q_log_L(1:3,:) = q_log_L(1:3,:) + repmat((q_log_R(1:3,end)-q_log_R(1:3,1)),1,21);

t_log_R = tspan{1};
t_log_L = t_log_R + t_log_R(end);

q_log = [q_log_R, q_log_L];
t_log = [t_log_R, t_log_L];
%%
anim = Animator.FiveLinkAnimator(t_log, q_log);
anim.pov = Animator.AnimatorPointOfView.West;
anim.Animate(true);
anim.isLooping = false;
anim.updateWorldPosition = true;
anim.endTime = 20;

conGUI = Animator.AnimatorControls();
conGUI.anim = anim;
figure
hold on;
line([0.5 0.5], [0,0.05]); hold on;
line([0.5 0.5+1.2],[0.05 0.05])



