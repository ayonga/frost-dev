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


%% add a new edge (left toe strike)
atlas_multiwalk_opt = atlas_multiwalk;

left_toe_strike_relabel = LeftToeStrikeRelabel(atlas);
atlas_multiwalk_opt = addEdge(atlas_multiwalk_opt, 'RightHeelStrike', 'RightToeStrike', 'Guard', left_toe_strike_relabel);
atlas_multiwalk_opt = rmVertex(atlas_multiwalk_opt, {'LeftToeStrike', 'LeftToeLift', 'LeftHeelStrike'});


nlp_atlas_multi = HybridTrajectoryOptimization(atlas_multiwalk_opt);
nlp_atlas_multi = initializeNLP(nlp_atlas_multi);
nlp_atlas_multi = configureOptVariables(nlp_atlas_multi);
nlp_atlas_multi = configureConstraints(nlp_atlas_multi);

for i=1:3
    nlp_atlas_multi = addRunningCost(nlp_atlas_multi, i, nlp_atlas_multi.Funcs.Phase{i}.power);
end
compileSymFunction(nlp_atlas_multi, 'Phase', [1,2,3], export_path);


solver = IpoptApplication(nlp_atlas_multi);

[sol, info] = optimize(solver);
