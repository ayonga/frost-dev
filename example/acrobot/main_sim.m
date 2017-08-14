%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Specify project path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
root_path = get_project_path();
export_path = fullfile(root_path,'export','sim');
if ~exist(export_path,'dir')
    mkdir(export_path);
end
addpath(export_path);

%%
robot = acrobot();
robot.configureDynamics();

[frame, fric_coef, geom] = get_contact_frame(robot);
robot = addContact(robot,frame,fric_coef,geom);



%% relative degree two outputs:
ya_2 = robot.States.x(4:end);
t = SymVariable('t');
p = SymVariable('p',[2,1]);
tau = (t-p(2))/(p(1)-p(2));
y2 = VirtualConstraint(robot,ya_2,'joints','DesiredType','Bezier','PolyDegree',5,...
    'RelativeDegree',2,'PhaseType','TimeBased',...
    'PhaseVariable',tau,'PhaseParams',p,'Holonomic',true);

robot = addVirtualConstraint(robot,y2);

%%
robot.compile(export_path);
%%
params.ajoints = [ones(1,6)*0.1;zeros(2,6)];
params.pjoints = [0,1];
params.kjoints = [100,20]; %[kp,kd]

t0 = 0;
tf = 10;
eventnames = [];
sim_opts = [];
logger = SimLogger(robot);
x0 = [zeros(6,1);zeros(6,1)];
io_control  = IOFeedback('IO');
tic
robot.simulate(t0, x0, tf, io_control, params, logger, eventnames, sim_opts);
toc

%%
[conGUI] = load_animator(robot, logger.flow.t, logger.flow.states.x)

%%
t = logger.flow.t;
force = logger.flow.inputs.ConstraintWrench.ffoot;
plot_zmp(t,force);