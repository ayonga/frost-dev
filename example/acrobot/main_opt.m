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
nlp = Opt.LoadProblem(sys);

%%
[nlp, bounds]  = Opt.UpdateBounds(nlp, sys);

%% 
load('res/gaits/push-0_00p.mat')
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
%%
force_list = [5,10,15];
names = {'res/gaits/push-5_00p'
    'res/gaits/push-10_00p'
    'res/gaits/push-15_00p'};
for i=1:length(force_list)
    
    bounds.step1.push_force(1) = force_list(i);
    nlp.Phase(1).Plant.UserNlpConstraint(nlp.Phase(1),bounds.step1);
    
    nlp.update();
    
    Opt.LoadInitialGuess(nlp,gait);
    [gait, info, sol] = Opt.SolveProblem(nlp);
    
    if info.status == 0 || info.status==1 || info.status==-2
        save(names{i},'gait','bounds','sol','info');
    else
        save([names{i},'_failed'],'gait','bounds','sol','info');
    end
end

load('res/gaits/push-0_00p.mat')
force_list = [-5,-10,-15];
names = {'res/gaits/push-5_00m'
    'res/gaits/push-10_00m'
    'res/gaits/push-15_00m'};
for i=1:length(force_list)
    
    bounds.step1.push_force(1) = force_list(i);
    nlp.Phase(1).Plant.UserNlpConstraint(nlp.Phase(1),bounds.step1);
    
    nlp.update();
    
    Opt.LoadInitialGuess(nlp,gait);
    [gait, info, sol] = Opt.SolveProblem(nlp);
    
    if info.status == 0 || info.status==1 || info.status==-2
        save(names{i},'gait','bounds','sol','info');
    else
        save([names{i},'_failed'],'gait','bounds','sol','info');
    end
end