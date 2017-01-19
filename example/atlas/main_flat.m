addpath('export');
addpath('param');
addpath('urdf');
% run options
compile_expr = true;
export_expr  = true;
build_expr   = true;
cur = fileparts(mfilename('fullpath'));
export_path = fullfile(cur, 'export');
atlas = Atlas('urdf/atlas_simple_contact_noback.urdf');

if compile_expr
    re_load = true;
    initialize(atlas, re_load);
    
    % compile dynamics
    atlas = compileDynamics(atlas);
    atlas = compileCoM(atlas);
    
    if export_expr
        exportDynamics(atlas, export_path, build_expr);
        exportCoM(atlas, export_path, build_expr);        
    end
end

RightStance = VirtualConstrDomain('RightSSFlatWalking');
RightStance = addContact(RightStance,{atlas.Contacts.RightFoot});
RightStance = addHolonomicConstraint(RightStance, atlas.FixedDofs);
RightStance = addUnilateralConstraint(RightStance, atlas.Kins.LeftFootPosZ);

act_joints = atlas.Joints(strcmp('revolute',{atlas.Joints.type}));
RightStance = setAcutation(RightStance, atlas, {act_joints.name});

RightStance = setPhaseVariable(RightStance, 'StateBased', atlas.Kins.RightTau);
RightStance = setVelocityOutput(RightStance, atlas.Kins.RightDeltaPhip, 'Constant');
RightStance = addPositionOutput(RightStance, ...
    {atlas.Kins.RightAnkleRoll,...
    atlas.Kins.RightKneePitch,...
    atlas.Kins.RightTorsoPitch,...
    atlas.Kins.RightTorsoRoll,...
    atlas.Kins.RightHipYaw,...
    atlas.Kins.LeftKneePitch,...
    atlas.Kins.LeftLinNSlope,...
    atlas.Kins.LeftLegRoll,...
    atlas.Kins.LeftFootRoll,...
    atlas.Kins.LeftFootPitch,...
    atlas.Kins.LeftFootYaw}, 'Bezier5thOrder');

if compile_expr
    compile(RightStance, atlas, true);
    if export_expr
        export(RightStance, export_path, build_expr);
    end
end

LeftStance = VirtualConstrDomain('LeftSSFlatWalking');
LeftStance = addContact(LeftStance,{atlas.Contacts.LeftFoot});
LeftStance = addHolonomicConstraint(LeftStance, atlas.FixedDofs);
LeftStance = addUnilateralConstraint(LeftStance, atlas.Kins.RightFootPosZ);

act_joints = atlas.Joints(strcmp('revolute',{atlas.Joints.type}));
LeftStance = setAcutation(LeftStance, atlas, {act_joints.name});

LeftStance = setPhaseVariable(LeftStance, 'StateBased', atlas.Kins.LeftTau);
LeftStance = setVelocityOutput(LeftStance, atlas.Kins.LeftDeltaPhip, 'Constant');
LeftStance = addPositionOutput(LeftStance, ...
    {atlas.Kins.LeftAnkleRoll,...
    atlas.Kins.LeftKneePitch,...
    atlas.Kins.LeftTorsoPitch,...
    atlas.Kins.LeftTorsoRoll,...
    atlas.Kins.LeftHipYaw,...
    atlas.Kins.RightKneePitch,...
    atlas.Kins.RightLinNSlope,...
    atlas.Kins.RightLegRoll,...
    atlas.Kins.RightFootRoll,...
    atlas.Kins.RightFootPitch,...
    atlas.Kins.RightFootYaw}, 'Bezier5thOrder');
if compile_expr
    compile(LeftStance, atlas, true);
    if export_expr
        export(LeftStance, export_path, build_expr);
    end
end

io_control  = IOFeedback('IO');
param_config_file = 'param/params_2016-07-01T13-17-04-00.yaml';
old_params = cell_to_matrix_scan(yaml_read_file(param_config_file));
params = cell(1,2);
for i=1:2
    params{i}.a = old_params.domain(i).a;
    params{i}.v = old_params.domain(i).v;
    params{i}.p = old_params.domain(i).p(1:2)';    
end
AtlasFlatWalking = HybridSystem('AtlasFlatWalking', atlas);
AtlasFlatWalking = addVertex(AtlasFlatWalking, 'RightStance', 'Domain', RightStance, ...
    'Control', io_control,'Param', params{1});
AtlasFlatWalking = addVertex(AtlasFlatWalking, 'LeftStance', 'Domain', LeftStance, ...
    'Control', io_control,'Param', params{2});

LeftFootStrike = Guard('LeftFootStrike',...
    'Condition', 'LeftFootPosZ',...
    'Direction', -1,...
    'DeltaOpts', struct('ApplyImpact',true));
RightFootStrike = Guard('RightFootStrike',...
    'Condition', 'RightFootPosZ',...
    'Direction', -1,...
    'DeltaOpts', struct('ApplyImpact',true));
srcs = {'RightStance','LeftStance'};
tars = {'LeftStance','RightStance'};
AtlasFlatWalking = addEdge(AtlasFlatWalking, srcs, tars);
AtlasFlatWalking = setEdgeProperties(AtlasFlatWalking, srcs, tars, 'Guard',...
    {LeftFootStrike,...
    RightFootStrike});
%%
old_dofs = {'BasePosX'
    'BasePosY'
    'BasePosZ'
    'BaseRotX'
    'BaseRotY'
    'BaseRotZ'
    'l_leg_hpz'
    'l_leg_hpx'
    'l_leg_hpy'
    'l_leg_kny'
    'l_leg_aky'
    'l_leg_akx'
    'r_leg_hpz'
    'r_leg_hpx'
    'r_leg_hpy'
    'r_leg_kny'
    'r_leg_aky'
    'r_leg_akx'};
q0 = zeros(atlas.nDof,1);
dq0 = zeros(atlas.nDof,1);
q0_old = old_params.domain(1).x_plus(1:18);
dq0_old = old_params.domain(1).x_plus(19:end);
for i=1:atlas.nDof
    idx = find(strcmp(atlas.Dof(i).name,old_dofs));
    if isempty(idx)
        q0(i) = 0;
        dq0(i) = 0;
    else
        q0(i) = q0_old(idx);
        dq0(i) = dq0_old(idx);
    end
end
%%
opts.x0 = [q0;dq0];
simulate(AtlasFlatWalking, opts);
