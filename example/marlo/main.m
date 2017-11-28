% Main script


%% Setting up path
clear; close all; clc;
restoredefaultpath; matlabrc;

export_path = 'gen/opt';
load_path   = [];%'gen/sym';
utils.init_path(export_path);

%% initialize model settings
cur = utils.get_root_path();
urdf = fullfile(cur,'urdf','atrias.urdf');
delay_set = false;
%% load robot model
tic
robot = sys.LoadModel(urdf, load_path, delay_set);

% load hybrid system
system = sys.LoadSystem(robot, load_path);

% get Bounds
bounds = opt.GetBounds(robot);

% load problem
nlp = opt.LoadProblem(system, bounds, load_path);
toc
%% Compile stuff if needed
% compileConstraint(nlp,[],[],export_path,{'dynamics_equation'});
% compileObjective(nlp,[],[],export_path);
% compileConstraint(nlp,[],[],export_path);
% % Save expression 
% load_path   = 'gen/sym';
% system.saveExpression(load_path); % run this after loaded the optimization problem

%% gait library




%% update bounds
bounds = opt.GetBounds(robot);
opt.updateVariableBounds(nlp, bounds);
% update initial condition
param = load('local/good_gait.mat');

opt.updateInitCondition(nlp,param.gait);
%% solve
[gait, sol, info] = opt.solve(nlp);

%% save
save('local/good_gait.mat','gait','sol','info','bounds');

%% animation
anim = plot.LoadAnimator(robot, gait,'SkipExporting',true);