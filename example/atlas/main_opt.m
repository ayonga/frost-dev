% Main script


%% Setting up path
clear; close all; clc;
restoredefaultpath; matlabrc;

% specify the path to the FROST
frost_path  = '../../';
addpath(frost_path);
frost_addpath; % initialize FROST
export_path = 'gen/opt'; % path to export compiled C++ and MEX files
utils.init_path(export_path);
%% robot model settings
cur = utils.get_root_path();
urdf = fullfile(cur,'urdf','atlas_simple_contact_noback.urdf');

% some options

% if 'delay_set' is true, the computation of system dynamics (Coriolis
% vector) will be delayed. Delaying this operation will save significant
% loading time.
delay_set = true;

% if 'load_sym' is true, it will load symbolic expressions from previously
% save external files instead of re-compute them. It reduce the loading
% time by 7-10 faster. 
% Set it to false for the first time, and save expressions after loaded the
% model. 
load_sym  = false; % if true, it will load symbolic expression from 
if load_sym    
    load_path   = 'gen/sym'; % path to export binary Mathematica symbolic expression (MX) files
    utils.init_path(load_path);
else
    load_path   = []; 
end
%% load robot model
% load the robot model
robot = sys.LoadModel(urdf, load_path, delay_set);

% load hybrid system
system = sys.LoadSystem(robot, load_path);

%% Load optimization problem
% get the boundary values, needs to be manually set all boundaries.
bounds = opt.GetBounds(robot);

% load problem
nlp = opt.LoadProblem(system, bounds, load_path);

%% Compile stuff if needed (only need to run for the first time)
compileObjective(nlp,[],[],export_path);

% % exclude dynamics_equations
% compileConstraint(nlp,[],[],export_path,{'dynamics_equation'}); 

% % compile everything
compileConstraint(nlp,[],[],export_path);

% % compile intX and intXdot for phase 1 and 3
% compileConstraint(nlp,[1,3],{'intX','intXdot'},export_path);

% other possible ways to compile 
% funcs = [nlp.Phase(1).ConstrTable.dynamics_equation(1).SummandFunctions(end-2:end);
%     nlp.Phase(3).ConstrTable.dynamics_equation(1).SummandFunctions(end-2:end)];
% for i=1:length(funcs)
%     fun = funcs(i);
%     export(fun.SymFun,export_path);
%     exportJacobian(fun.SymFun,export_path);
% end
% 
% compileConstraint(nlp,2,'dxDiscreteMapLeftImpact',export_path);
% compileConstraint(nlp,4,'dxDiscreteMapRightImpact',export_path);
compileConstraint(nlp,[],{'y_position_RightStance'
    'd1y_position_RightStance'
    'position_output_dynamics'
    'y_position_LeftStance'
    'd1y_position_LeftStance'},export_path);
% compileConstraint(nlp,'RightStance',{...
%     'step_distance_RightStance'},export_path);
%% Save expression (only need to run for the first time)
load_path   = 'gen/sym';
utils.init_path(load_path);
system.saveExpression(load_path); % run this after loaded the optimization problem



%% you can update bounds without reloading the problem. It is much much faster!!!
bounds = opt.GetBounds(robot);
opt.updateVariableBounds(nlp, bounds);

% removeConstraint(nlp.Phase(1),'u_friction_cone_RightSole');
% removeConstraint(nlp.Phase(1),'u_zmp_RightSole');
% removeConstraint(nlp.Phase(3),'u_friction_cone_LeftSole');
% removeConstraint(nlp.Phase(3),'u_zmp_LeftSole');


%% update initial condition if use pre-existing gaits
param = load('local/tmp_gait.mat');
opt.updateInitCondition(nlp,param.gait);



%% solve (two ways to call "solve")
% 1. If use the typical variables values as the initial guess
% 2. If use existing solutoin as the initial guess
%[gait, sol, info] = opt.solve(nlp, sol); % if use previous solution "sol"
% 3. warm start using use existing solutoin as the initial guess
%[gait, sol, info] = opt.solve(nlp, sol, info); % if use previous solution "sol"
[gait, sol, info] = opt.solve(nlp);



%% save
save('local/tmp_gait.mat','gait','sol','info','bounds');



%% animation
anim = plot.LoadOptAnimator(robot, gait,'SkipExporting',true);



%% you can check the violation of constraints/variables and the value of each cost function by calling the following functions.
tol = 1e-3;
checkConstraints(nlp,sol,tol,'local/constr_check.txt') % 
checkVariables(nlp,sol,tol,'local/var_check.txt') % 

checkCosts(nlp,sol,'local/cost_check.txt') % 



%% you can also plot the states and torques w.r.t upper/lower bounds.
plot.plotOptStates(robot,nlp,gait);
plot.plotOptTorques(robot,nlp,gait);


