% run options
compile_expr = false;
export_expr  = false;
build_expr   = false;
cur = fileparts(mfilename('fullpath'));
addpath([cur, '/export']);
addpath([cur, '/param']);
addpath([cur, '/urdf']);
export_path = fullfile(cur, 'export');
atlas = Atlas([cur,'/urdf/atlas_simple_contact_noback.urdf']);

atlas_multiwalk = Atlas3DMultWalking(atlas);

% atlas_multiwalk = compile(atlas_multiwalk, atlas, export_path);

old_param_file = [cur,'/param/params_2016-07-24T00-48-04-00.yaml'];

atlas_multiwalk = loadParam(atlas_multiwalk, old_param_file, atlas);

atlas_multiwalk = simulate(atlas_multiwalk);

