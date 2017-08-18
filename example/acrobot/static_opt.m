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
robot.UserNlpConstraint = @CstrFcns.StaticStepConstraints;

%%
nlp = Opt.LoadProblem(robot);
%%
% Opt.Compile(nlp, export_path,{'zmpPos_acrobot'});
%%
[nlp, bounds]  = Opt.UpdateBounds(nlp, robot);

%% 
param = load('res/static_pose.mat');
gait = param.gait;
%%foot_link
Opt.LoadInitialGuess(nlp,gait);


%%

[gait, info, sol] = Opt.SolveProblem(nlp);

%%

[conGUI] = Plot.LoadAnimator(robot, gait);

%% 
Plot.plotZmp(robot,nlp,gait);

%%
Plot.plotOptStates(robot,nlp,gait);

%%
rcom_list = [0.3,0.4,0.5,0.6,0.7];
thcom_list = [72,78,84,90,96];
prefix = 'res/gaits/static_';
status = zeros(length(rcom_list),length(thcom_list));
for i=1:length(rcom_list)
    for j=1:length(thcom_list)
        if i~=2 || j~=1
            continue;
        end
        name = [prefix,'r-',num2str(rcom_list(i)),'_th=',num2str(thcom_list(j))];
        name = strrep(name,'.','-');
        bounds.rcom.lb = rcom_list(i)-0.02;
        bounds.rcom.ub = rcom_list(i)+0.02;
        bounds.thetacom.lb = deg2rad(thcom_list(j)-2);
        bounds.thetacom.ub = deg2rad(thcom_list(j)+2);
        [nlp, bounds]  = Opt.UpdateBounds(nlp, robot, bounds);
        Opt.LoadInitialGuess(nlp,param.gait);
        
        [gait, info, sol] = Opt.SolveProblem(nlp);
        
        if info.status == 0 || info.status==1 || info.status==-2 || info.status==2
            save(name,'gait','bounds','sol','info');
            status(i,j) = 1;
        else
            %             keyboard
            save([name,'_failed'],'gait','bounds','sol','info');
        end
    end
    
end


    
    