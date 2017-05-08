%% The main script to run the FLIPPY multi-contact walking simulation
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
%%%% FLIPPY robot model object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
urdf_file = fullfile(cur,'urdf','robot_only_arm_noeff.urdf');
%@note you could directly create an object, instead of making new subclass.
base = get_base_dofs('fixed');
flippy = RobotLinks(urdf_file,base);
flippy.configureDynamics();

% holonomic constraints??? 
% obj.addHolonomicConstraints(constr);


% contacts???
% wrist_3_link = flippy.Links(getLinkIndices(flippy, 'wrist_3_link'));
% wrist_3_frame = wrist_3_link.Reference;
% % wrist_3_joint = obj.Joints(getJointIndices(obj, 'r_leg_akx'));
% EndEff = ContactFrame(...
%     'Name','EndEff',...
%     'Reference',wrist_3_frame,...
%     'Offset',[0, 0, 0],...
%     'R',[0,0,0]... % z-axis is the normal axis, so no rotation required
%     );
% EndEff_contact = ToContactFrame(EndEff,'PlanarContactWithFriction');
% flippy.addContact(EndEff);


% unilateral constraints???
q = flippy.States.x; % symbolic variable for joint configuration
q_wr = q('wrist_3_joint'); % waist roll joint. The following two referencing both works: q('wrist_3_joint') == q(6);
delta_final =  - q_wr + pi; % 
u_delta_final = UnilateralConstraint(flippy,delta_final,'deltafinal','x'); %'x' represents joint configuration here, the delta_final is function of x

% unilateral constraints will be automatically imposed as path constraint
% in the trajectory optimization. They won't affects the simulation
% process.
% addUnilateralConstraints(obj, constr)
%
% If wants to use unilateral constraints to trigger events in simulation,
% add them as event functions
% addEvent(obj, event)
addEvent(flippy, u_delta_final);


% % virtual constraints???
% tau
p = SymVariable('p',[2,1]);
tau = (q_wr-p(2))/(p(1)-p(2));

% y1 = dq_wr
ya1 = jacobian(q_wr, flippy.States.x)*flippy.States.dx;
y1_name = 'vel';
y1 = VirtualConstraint(flippy, ya1, y1_name,...
    'DesiredType','Constant',...
    'RelativeDegree',1,'OutputLabel',{'WristRoll'},'PhaseType','StateBased',...
    'Holonomic',false);

% % y2 
% obj = addPositionOutput(obj, ...
%                 {model.KinObjects.ShoulderPan,...
%                 model.KinObjects.ShoulderLift,...
%                 model.KinObjects.Elbow,...
%                 model.KinObjects.WristYaw,...
%                 model.KinObjects.WristPitch}, ...
%                 'Bezier6thOrder');
y_sp = q('shoulder_pan_joint');
y_sl = q('shoulder_lift_joint');
y_el = q('elbow_joint');
y_wp = q('wrist_1_joint');
y_wy = q('wrist_2_joint');
ya_2 = [y_sp; y_sl; y_el; y_wy; y_wp];
    
y2_label = {'ShoulderPan',...
    'ShoulderLift',...
    'Elbow',...
    'WristYaw',...
    'WristPitch'};
y2_name = 'pos';
y2 = VirtualConstraint(flippy, ya_2, y2_name,...
    'DesiredType','Bezier','PolyDegree',6,...
    'RelativeDegree',2,'OutputLabel',{y2_label},'PhaseType','StateBased',...
    'PhaseVariable',tau,'PhaseParams',p,'Holonomic',true);
flippy = addVirtualConstraint(flippy,y1);
flippy = addVirtualConstraint(flippy,y2);

io_control  = IOFeedback('IO');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Compile and export model specific functions
%%%% (uncomment the following lines when run it for the first time.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% flippy.compile(export_path);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Load Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
old_param_file = [cur,'/param/flippy_move_2017_05_02_1855.yaml'];

[params,x0] = loadParam(old_param_file);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Run the simulator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% you can assign these function handle to have additional processing
% functions in the simulation
flippy.PreProcess = str2func('nop'); %called before ode
flippy.PostProcess = str2func('nop');% called after ode
% flippy.UserNlpConstraint = str2func('nop');


t0 = 0;
tf = 10;
eventnames = 'deltafinal';
sim_opts = [];
tic
flippy.simulate(t0, x0, tf, io_control, params, eventnames, sim_opts)
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Run the animator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% export_file = fullfile(cur,'tmp','flippy_move.avi');
% anim_obj = animator(flippy);
% anim_obj.Options.ViewAngle=[39,24];
% anim_obj.animate(flippy_move.Flow, export_file);
