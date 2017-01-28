% run options

cur = fileparts(mfilename('fullpath'));
addpath(genpath(cur));
export_path = fullfile(cur, 'export');
atlas = Atlas([cur,'/urdf/atlas_simple_contact_noback.urdf']);

atlas_multiwalk = Atlas3DMultWalking(atlas);

% atlas_multiwalk = compile(atlas_multiwalk, atlas, export_path);

old_param_file = [cur,'/param/params_2016-07-24T00-48-04-00.yaml'];

atlas_multiwalk = loadParam(atlas_multiwalk, old_param_file, atlas);

atlas_multiwalk = simulate(atlas_multiwalk);

%% add a new edge (left toe strike)
atlas_multiwalk_opt = Atlas3DMultiWalkingOpt(atlas_multiwalk);

atlas_multiwalk_opt = update(atlas_multiwalk_opt);

% for i=1:3
%     compileSymFunction(atlas_multiwalk_opt, 'Phase', i, export_path);
% end
% 
solver = IpoptApplication(atlas_multiwalk_opt);
% 
[sol, info] = optimize(solver);
