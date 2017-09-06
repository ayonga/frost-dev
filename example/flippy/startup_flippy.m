
flippy_export = false;

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
% urdf_file = fullfile(cur,'urdf','fanuc_lrmate200id-7lc-6DOF.urdf');
urdf_file = fullfile(cur,'urdf','fanuc_lrmate200id-7lc-6DOFJ6turned.urdf');
%@note you could directly create an object, instead of making new subclass.
base = get_base_dofs('fixed');
flippy = RobotLinks(urdf_file,base);
flippy.configureDynamics();

% holonomic constraints??? 
% obj.addHolonomicConstraints(constr);


% % % unilateral constraints???
q = flippy.States.x; % symbolic variable for joint configuration
% q_wr = q('joint_6'); % waist roll joint. The following two referencing both works: q('wrist_3_joint') == q(6);
% delta_final =  - q_wr + pi; % 
% u_delta_final = UnilateralConstraint(flippy,delta_final,'deltafinal','x'); %'x' represents joint configuration here, the delta_final is function of x

% unilateral constraints will be automatically imposed as path constraint
% in the trajectory optimization. They won't affects the simulation
% process.
% addUnilateralConstraints(obj, constr)
%
% If wants to use unilateral constraints to trigger events in simulation,
% add them as event functions
% addEvent(obj, event)
% addEvent(flippy, u_delta_final);


% % virtual constraints???
% tau
% p = SymVariable('p',[2,1]);
% tau = (q_wr-p(2))/(p(1)-p(2));

% % y1 = dq_ee
% ya1 = jacobian(q_ee, flippy.States.x)*flippy.States.dx;
% y1_name = 'vel';
% y1 = VirtualConstraint(flippy, ya1, y1_name,...
%     'DesiredType','Constant',...
%     'RelativeDegree',1,'OutputLabel',{'EndEffector'},'PhaseType','StateBased',...
%     'Holonomic',false);

% % y2 
y_sp = q('joint_1');
y_sl = q('joint_2');
y_el = q('joint_3');
y_w1 = q('joint_4');
y_w2 = q('joint_5');
y_w3 = q('joint_6');
ya_2 = [y_sp; y_sl; y_el; y_w1; y_w2; y_w3];
    
y2_label = {'ShoulderPan',...
    'ShoulderLift',...
    'Elbow',...
    'WristYaw',...
    'WristPitch'...
    'WristRoll'};
y2_name = 'pos';
% t = SymVariable('t');
% tau = (t-p(2))/(p(1)-p(2));
y2 = VirtualConstraint(flippy, ya_2, y2_name,...
    'DesiredType','Bezier','PolyDegree',6,...
    'RelativeDegree',2,'OutputLabel',{y2_label},'PhaseType','TimeBased',...
    'Holonomic',true);
%flippy = addVirtualConstraint(flippy,y1);
flippy = addVirtualConstraint(flippy,y2);

io_control  = IOFeedback('IO');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Compile and export model specific functions
%%%% (uncomment the following lines when run it for the first time.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flippy_export
    flippy.compile(export_path);
end
