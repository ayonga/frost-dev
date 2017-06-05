%% The main script to run the FLIPPY multi-contact walking simulation

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
urdf_file = fullfile(cur,'urdf','robot_only_arm.urdf');
%@note you could directly create an object, instead of making new subclass.
base = get_base_dofs('fixed');
flippy = RobotLinks(urdf_file,base);
flippy.configureDynamics();

% holonomic constraints??? 
% obj.addHolonomicConstraints(constr);


% unilateral constraints???
q = flippy.States.x; % symbolic variable for joint configuration
q_ee = q('ee_fixed_joint'); % waist roll joint. The following two referencing both works: q('wrist_3_joint') == q(6);
delta_final =  - q_ee + pi; % 
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
tau = (q_ee-p(2))/(p(1)-p(2));

% y1 = dq_ee
ya1 = jacobian(q_ee, flippy.States.x)*flippy.States.dx;
y1_name = 'vel';
y1 = VirtualConstraint(flippy, ya1, y1_name,...
    'DesiredType','Constant',...
    'RelativeDegree',1,'OutputLabel',{'EndEffector'},'PhaseType','StateBased',...
    'Holonomic',false);

% % y2 
y_sp = q('shoulder_pan_joint');
y_sl = q('shoulder_lift_joint');
y_el = q('elbow_joint');
y_wp = q('wrist_1_joint');
y_wy = q('wrist_2_joint');
y_wr = q('wrist_3_joint');
ya_2 = [y_sp; y_sl; y_el; y_wy; y_wp; y_wr];
    
y2_label = {'ShoulderPan',...
    'ShoulderLift',...
    'Elbow',...
    'WristYaw',...
    'WristPitch'...
    'WristRoll'};
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
flippy.compile(export_path);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Load Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
old_param_file = [cur,'/param/fanuc_2017_05_18_2147.yaml'];

[params,x0] = loadParam(old_param_file);

%%
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
logger = SimLogger(flippy);
tic
flippy.simulate(t0, x0, tf, io_control, params, logger, eventnames, sim_opts);
toc

%% Plot the Data
figure(200);
logger;
plot(logger.flow.t,logger.flow.states.x(1:6,:));
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Run the animator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% export_file = fullfile(cur,'tmp','flippy_move.avi');
% anim_obj = animator(flippy_move);
% anim_obj.Options.ViewAngle=[39,24];
% anim_obj.animate(flippy_move.Flow, export_file);
