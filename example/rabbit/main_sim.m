%% Initialize the workspace and frost paths:
clear; clc;
restoredefaultpath;
addpath('../../');
frost_addpath();
addpath(genpath("model"));
addpath(genpath("sim"));
%%
[rabbit, rabbit_1step] = load_model('urdf/five_link_walker.urdf');
%%
COMPILE = 1;
export_path = 'gen/';
if COMPILE
    if ~isfolder([export_path, 'sim/'])
        mkdir([export_path, 'sim/'])
    end
    compile(rabbit_1step,[export_path, 'sim/']);
    export(rabbit_1step.Gamma.Nodes.Domain{1}.VirtualConstraints.Outputs, [export_path, 'sim/']);
end
rabbit_1step.saveExpression('./gen/sym');
%% setup feedback controller
load('gait.mat');
joint_torque = rabbit.Inputs.torque;
joint_torque.CallbackFunction = @computed_torques;
Params.kp = 400;
Params.kd = 20;
Params.a = reshape(gait(1).params.aOutputs,4,5);
Params.p = gait(1).params.pOutputs;
joint_torque.Params = Params;

%% custom event function
event_fcn_obj = rabbit_1step.Gamma.Nodes.Domain{1}.EventFuncs.nsf_height;
event_fcn_obj.CustomEventFunc = @custom_delayed_event;

%% pre-process
r_stance = rabbit_1step.Gamma.Nodes.Domain{1};
r_stance.PreIntegrationCallback = @pre_process;
%% simulate
addpath('gen/sim');
load('gait.mat');
x0  = [gait(1).states.x(:,1); gait(1).states.dx(:,1)];
opts = struct;
[logger] = simulate(rabbit_1step, x0, 0, 1, opts, 'NumCycle',1);

%%
anim = LoadSimAnimator(rabbit,logger,'SkipExporting',true,'ExportPath','gen/sim');