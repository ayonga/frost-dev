% Main script


%% Setting up path
clear; close all; clc;
restoredefaultpath; matlabrc;

export_path = 'gen/opt';
load_path   = 'gen/sym';
% load_path  = [];
utils.init_path(export_path);

%% initialize model settings
cur = utils.get_root_path();
urdf = fullfile(cur,'urdf','atrias.urdf');
delay_set = false;
%% load robot model
tic
robot = sys.LoadModel(urdf, load_path, delay_set);

% load hybrid system
system = sys.LoadTransSystem(robot, load_path);


bounds = trans_opt.GetBounds(robot);

% load problem
param = load('local/good_gait.mat');
nlp = trans_opt.LoadProblem(system, bounds, param.gait, load_path);
toc
%% Compile stuff if needed
compileConstraint(nlp,[],[],export_path,{'dynamics_equation'});
compileObjective(nlp,[],[],export_path);
% compileConstraint(nlp,[],[],export_path);
% % Save expression 
load_path   = 'gen/sym';
system.saveExpression(load_path); % run this after loaded the optimization problem

%% gait library
param = load(fullfile('local','library5','transition','gait_X0.0_Y0.8_TO_X0.0_Y0.0_Failed.mat'));
% trans_opt.updateVariableBounds(nlp, param.bounds);

% checkConstraints(nlp, param.sol, 1e-3, 'local/constr.txt')
% checkVariables(nlp, param.sol, 1e-3,'local/var.txt')
% 
% plot.plotOptTorques(robot,nlp,param.gait)
% plot.plotOptStates(robot,nlp,param.gait)

anim = plot.LoadAnimator(robot, param.gait,'SkipExporting',true);
%% update bounds
% bounds = opt.GetBounds(robot);
% opt.updateVariableBounds(nlp, bounds);
% % update initial condition
% param = load('local/good_gait.mat');
% 
% opt.updateInitCondition(nlp,param.gait);
% %% solve
% [gait, sol, info] = opt.solve(nlp, sol);
% 
% %% save
% save('local/good_gait.mat','gait','sol','info','bounds');

%% animation
anim = plot.LoadAnimator(robot, gait,'SkipExporting',true);