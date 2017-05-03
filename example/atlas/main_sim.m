%% The main script to run the ATLAS flat-footedwalking simulation
% 
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Specify project path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cur = fileparts(mfilename('fullpath'));
addpath(genpath(cur));
export_path = fullfile(cur, 'export');
if ~exist(export_path,'dir')
    mkdir(export_path);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% ATLAS robot model object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
urdf = fullfile(cur,'urdf','atlas_simple_contact_noback.urdf');
atlas = AtlasRobot(urdf);
atlas.configureDynamics();


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% Hybrid system model for the flat-footed walking of ATLAS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% flat-footed wakling:
% RightStance -> LeftImpact -> LeftStance -> RightImpact
%      ^                                         |
%      |_________________________________________|
r_stance = RightStance(atlas);
l_stance = LeftStance(atlas);
r_impact = RightImpact(r_stance);
l_impact = LeftImpact(l_stance);

io_control  = IOFeedback('IO');

atlas_flat = HybridSystem('AtlasFlatWalking');
atlas_flat = addVertex(atlas_flat, 'RightStance', 'Domain', r_stance, ...
    'Control', io_control);
atlas_flat = addVertex(atlas_flat, 'LeftStance', 'Domain', l_stance, ...
    'Control', io_control);

srcs = {'RightStance'
    'LeftStance'};

tars = {'LeftStance'
    'RightStance'};

atlas_flat = addEdge(atlas_flat, srcs, tars);
atlas_flat = setEdgeProperties(atlas_flat, srcs, tars, ...
    'Guard', {l_impact, r_impact});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Compile and export model specific functions
%%%% (uncomment the following lines when run it for the first time.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% r_stance.compile(export_path);
% l_stance.compile(export_path);
% r_impact.compile(export_path);
% l_impact.compile(export_path);



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% Load Parameters
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
old_param_file = [cur,'/param/params_2016-07-01T13-17-04-00.yaml'];

new_param = loadOldParam(old_param_file, atlas);


% right-stance parameters
r_stance_param = struct;
r_stance_param.avelocity = new_param{1}.v;
r_stance_param.pvelocity = new_param{1}.p;
r_stance_param.aposition = new_param{1}.a;
r_stance_param.pposition = new_param{1}.p;
r_stance_param.kvelocity = 10;
r_stance_param.kposition = [100,20];
atlas_flat = setVertexProperties(atlas_flat,'RightStance','Param',r_stance_param);
% left-stance parameters
l_stance_param = struct;
l_stance_param.avelocity = new_param{2}.v;
l_stance_param.pvelocity = new_param{2}.p;
l_stance_param.aposition = new_param{2}.a;
l_stance_param.pposition = new_param{2}.p;
l_stance_param.kvelocity = 10;
l_stance_param.kposition = [100,20];
atlas_flat = setVertexProperties(atlas_flat,'LeftStance','Param',l_stance_param);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% Run the simulator
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x0 = [new_param{1}.q0;new_param{1}.dq0];
% run the single domain first (no hybrid system model)
% r_stance.simulate(0,x0,10,io_control,r_stance_param,'nsf',[]);
tic
atlas_flat.simulate(0, x0, [], [])
toc
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% Run the animator
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% export_file = fullfile(cur,'tmp','atlas_multi_contact_walking.avi');
% anim_obj = animator(atlas);
% anim_obj.animate(atlas_multiwalk.Flow, export_file);
