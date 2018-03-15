% Main script


%% Setting up path
clear; close all; clc;
restoredefaultpath; matlabrc;

% specify the path to the FROST
frost_path  = '../../';
addpath(frost_path);
frost_addpath; % initialize FROST
export_path = 'gen/sim'; % path to export compiled C++ and MEX files
utils.init_path(export_path);
% addpath('gen/sim');
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

%% load hybrid system
system = sys.LoadSystem(robot, load_path);



%% Compile stuff if needed (only need to run for the first time)
system.compile(export_path);

%% load optimal gait (and parameters)
param = load('local/tmp_gait.mat');
% right-stance parameters
r_stance_param = param.gait(1).params;
r_stance_param.epsilon = 10;
system = setVertexProperties(system,'RightStance','Param',r_stance_param);
% left-stance parameters
l_stance_param = param.gait(3).params;
l_stance_param.epsilon = 10;
system = setVertexProperties(system,'LeftStance','Param',l_stance_param);

%% configure pre process function
r_stance =system.Gamma.Nodes.Domain{1};
r_stance.PreProcess = @sim.RightStancePreProcess;
l_stance =system.Gamma.Nodes.Domain{2};
l_stance.PreProcess = @sim.LeftStancePreProcess;
%% run simulation
x0 = [param.gait(1).states.x(:,1);param.gait(1).states.dx(:,1)];
tic
logger = system.simulate(0, x0, [], [],'NumCycle',4);
toc

%% animation
anim = plot.LoadSimAnimator(robot, logger, 'SkipExporting',true);

%% you can also plot the states and torques
plot.plotSimStates(system,logger);
plot.plotSimTorques(system,logger);
