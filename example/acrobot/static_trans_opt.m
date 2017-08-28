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
% Opt.Compile(nlp, export_path,{'zmpPos_acrobot'});
%%
[nlp, bounds]  = Opt.UpdateBounds(nlp, sys);

%% 
source = load('initial_guess.mat');
gait = source.gait;
%%
Opt.LoadInitialGuess(nlp,gait);


%%

[gait, info, sol, solver] = Opt.SolveProblem(nlp);

%%

[conGUI] = Plot.LoadAnimator(robot, gait);

%% 
Plot.plotZmp(robot,nlp,gait);

%%
Plot.plotOptStates(robot,nlp,gait);

%%
rcom_list = [0.3,0.4,0.5,0.6,0.7];
thcom_list = [72,78,84,90,96];
prefix = 'res/gaits/static_trans_';
status = zeros(length(rcom_list),length(thcom_list));

target = load('res/gaits/static_r-0-7_th=84.mat', 'gait');

initial_guess = [target.gait,target.gait,target.gait];
initial_guess(2).states.xn = target.gait.states.x(:,1);
initial_guess(2).states.dxn = target.gait.states.dx(:,1);

for i=1:length(rcom_list)
    for j=1:length(thcom_list)
        %         if i==2 || j==1
        %             continue;
        %         end
        name = ['res/gaits/static_','r-',num2str(rcom_list(i)),'_th=',num2str(thcom_list(j))];
        name = strrep(name,'.','-');
        if exist([name,'_failed.mat'],'file') ~= 2
            continue;
        end
        source = load(name,'gait');
        initial_guess(1) = source.gait;
        initial_guess(2).states.x = source.gait.states.x(:,end);
        initial_guess(2).states.dx = source.gait.states.dx(:,end);
        
        bounds.step1.initialPos = [zeros(3,1);source.gait.states.x(4:end,1)];
        bounds.step1.initialVel = [zeros(3,1);source.gait.states.dx(4:end,1)];
        
        
        [nlp, bounds]  = Opt.UpdateBounds(nlp, sys, bounds);
        Opt.LoadInitialGuess(nlp,initial_guess);
        
        [gait, info, sol] = Opt.SolveProblem(nlp);
        
        keyboard
        name = [prefix,'r-',num2str(rcom_list(i)),'_th=',num2str(thcom_list(j))];
        name = strrep(name,'.','-');
        if info.status == 0 || info.status==1 || info.status==-2 || info.status==2
            save(name,'gait','bounds','sol','info');
            status(i,j) = 1;
        else
            %             keyboard
            save([name,'_failed'],'gait','bounds','sol','info');
        end
    end
    
end
