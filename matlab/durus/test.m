addpath ../
mathematica_setup
matlab_setup


cur = fileparts(mfilename('fullpath'));
config_file = fullfile(cur, 'durus_model.urdf');
export_path = fullfile(cur, 'export');


durus = RigidBodyModel(config_file);

durus.initialize(true);
qe =  rand(durus.nDof,1);
dqe = rand(durus.nDof,1);

% mass = getTotalMass(durus);
% durus = compileDynamics(durus);
% durus = compileCoM(durus);
% 
% status = exportDynamics(durus, export_path, true);
% status = exportCoM(durus, export_path, true);
% tic
% [De, He] = calcNaturalDynamics(durus,qe,dqe);
% toc
% tic
% [De_s, He_s] = calcNaturalDynamics(durus,qe,dqe,true);
% toc
% tol = 1e-8;
% assert(max(max(abs(De - De_s))) < tol);
% assert(max(abs(He - He_s)) < tol);

%%
right_foot = KinematicContact('Name','rightfoot');
right_foot.ParentLink = 'RightFootSpringLink';
right_foot.Offset = [0.07149,0,0];
right_foot.NormalAxis = '-x';
right_foot.ContactType = 'PlanarContactWithFriction';
right_foot.ModelType = durus.Type;
right_foot.Mu = 0.5;
right_foot.Geometry = {'y',[0.1,0.2];
    'z',[0.2,0.1]};

left_foot = KinematicContact('Name','leftfoot');
left_foot.ParentLink = 'LeftFootSpringLink';
left_foot.Offset = [0.07149,0,0];
left_foot.NormalAxis = '-x';
left_foot.ContactType = 'PlanarContactWithFriction';
left_foot.ModelType = durus.Type;
left_foot.Mu = 0.5;
left_foot.Geometry = {'y',[0.1,0.2];
    'z',[0.2,0.1]};

base_roll = KinematicDof('Name','brz');
base_roll.DofName = 'BaseRotZ';

nsf = KinematicPosition('Name','nsf');
nsf.ParentLink = 'LeftFootSpringLink';
nsf.Offset = [0.07149,0,0];
nsf.Axis = 'z';


%%
% right double support
RightDS = Domain('RightDS');
RightDS = addContact(RightDS,{right_foot,left_foot});
RightDS = addHolonomicConstraint(RightDS, base_roll);
RightDS = setAcutation(RightDS, durus, {durus.Dof(durus.qIndices).name});
% compileKinematics(RightDS, durus, true);
% exportKinematics(RightDS, export_path, true);

[vfc, gfc] = calcVectorFields(RightDS, durus, qe, dqe);
u = rand(size(RightDS.ActuationMap,2),1);
Fe = calcConstraintForces(RightDS, durus, qe, dqe, u);
% % right single support
RightSS = Domain('RightSS');
RightSS = addContact(RightSS,{right_foot});
RightSS = addHolonomicConstraint(RightSS, base_roll);
RightSS = addUnilateralConstraint(RightSS, nsf);
RightSS = setAcutation(RightSS, durus, {durus.Dof(durus.qIndices).name});
% compileKinematics(RightSS, durus, true);
% exportKinematics(RightSS, export_path, true);
% 
% % left double support
LeftDS = Domain('LeftDS');
LeftDS = addContact(LeftDS,{left_foot, right_foot});
LeftDS = addHolonomicConstraint(LeftDS, base_roll);
LeftDS = setAcutation(LeftDS, durus, {durus.Dof(durus.qIndices).name});
% compileKinematics(LeftDS, durus, true);
% exportKinematics(LeftDS, export_path, true);

% % Left single support
LeftSS = Domain('LeftSS');
LeftSS = addContact(LeftSS,{left_foot});
LeftSS = addHolonomicConstraint(LeftSS, base_roll);
LeftSS = addUnilateralConstraint(LeftSS, nsf);
LeftSS = setAcutation(LeftSS, durus, {durus.Dof(durus.qIndices).name});
% compileKinematics(LeftSS, durus, true);
% exportKinematics(LeftSS, export_path, true);
hs = HybridSystem();
hs = addVertex(hs, 'right_ds', 'Domain', RightDS);
hs = addVertex(hs, 'right_ss', 'Domain', RightSS);
hs = addVertex(hs, 'left_ds', 'Domain', LeftDS);
hs = addVertex(hs, 'left_ss', 'Domain', LeftSS);

srcs = {'right_ds','right_ss','left_ds','left_ss'};
tars = {'right_ss','left_ds','left_ss','right_ds'};
hs = addEdge(hs, srcs, tars);
hs = setEdgeProperties(hs, srcs, tars, 'Guard',...
    {'leftfoot_normal_force',...
    'nsf',...
    'rightfoot_normal_force',...
    'nsf'});
