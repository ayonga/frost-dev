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
% Opt.Compile(nlp, export_path,{'zmpPos_acrobot'});
%%
[nlp, bounds]  = Opt.UpdateBounds(nlp, robot);

%% 
param = load('res/static_pose.mat');
gait = param.gait;
%%
Opt.LoadInitialGuess(nlp,gait);


%%

[gait, info, sol] = Opt.SolveProblem(nlp);

%%

[conGUI] = Plot.LoadAnimator(robot, gait);

%% 
Plot.plotZmp(gait);

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
        bounds.rcom.lb = rcom_list(i);
        bounds.rcom.ub = rcom_list(i);
        bounds.thetacom.lb = deg2rad(thcom_list(j));
        bounds.thetacom.ub = deg2rad(thcom_list(j));
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
%%
% xcom_list = [-0.2, -0.15, -0.1, -0.05, 0];
% zcom_list = [0.45, 0.5, 0.55, 0.6, 0.65, 0.7];
% prefix = 'res/gaits/static_';
% for i=1:length(xcom_list)
%     for j=1:length(zcom_list)
%         name = [prefix,num2str(xcom_list(i)),'_',num2str(zcom_list(j))];
%         name = strrep(name,'.','-');
%         bounds.xcom.lb = xcom_list(i);
%         bounds.xcom.ub = xcom_list(i);
%         bounds.zcom.lb = zcom_list(j);
%         bounds.zcom.ub = zcom_list(j);
%         [nlp, bounds]  = Opt.UpdateBounds(nlp, robot, bounds);
%         Opt.LoadInitialGuess(nlp,param.gait);
%         
%         [gait, info, sol] = Opt.SolveProblem(nlp);
%         
%         if info.status == 0 || info.status==1 || info.status==-2
%             save(name,'gait','bounds','sol','info');
%         else
%             keyboard
%             save([name,'_failed'],'gait','bounds','sol','info');
%         end
%     end
%     
% end

    
    