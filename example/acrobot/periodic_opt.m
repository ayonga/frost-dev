%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Specify project path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all
root_path = utils.get_project_path();
export_path = fullfile(root_path,'export','opt');
if ~exist(export_path,'dir')
    mkdir(export_path);
end
addpath(export_path);
addpath('./tmp');
%%
[robot, sys] = Model.LoadModel();


%%
nlp = Opt.LoadProblem(robot);

%%
[nlp, bounds]  = Opt.UpdateBounds(nlp, robot);

%% 
param = load('res/static_pose.mat');
gait = param.gait;
%%
Opt.LoadInitialGuess(nlp,gait);
%%
% Opt.Compile(nlp, export_path,{'zmpPos_acrobot'});

%%

[gait, info, sol] = Opt.SolveProblem(nlp);

%%

[conGUI] = Plot.LoadAnimator(robot, gait);

%% 
Plot.plotZmp(gait);

%%
Plot.plotOptStates(robot,nlp,gait);

%%


    
    