
cur = fileparts(mfilename('fullpath'));
export_path = fullfile(cur,'export');
if ~exist(export_path)
    mkdir(export_path);
end
addpath(export_path);


%% create a truck model
vf = 20;
speed = vf;
horizon = 1;
bzorder = 5;
sys = truck(horizon,speed,bzorder);
% add an additional parameter of 'ymax'
% this will automatically impose required constraints for the parameter
% 'ymax'
ymax = SymVariable('ymax');
sys.addParam('ymax',ymax);


sys.UserNlpConstraint = str2func('truck_opt_constr');
x0=[0;vf;0;0;0;0;0;0];
rd=0;
bounds = boundary_value(sys,x0,rd);
%% construct a trajectory optimization problem for the truck model
opts = struct('ConstantTimeHorizon',[0,horizon]',... $NaN - variable time
    'DerivativeLevel',1,... % either 1 (only Jacobian) or 2 (both Jacobian and Hessian)
    'EqualityConstraintBoundary',0); % non-zero positive small value will relax the equality constraints
nlp = TrajectoryOptimization('truckopt',sys,10,bounds,opts);

truck_opt_cost(nlp, bounds);





nlp.update();
% 
compileConstraint(nlp,[],export_path);
compileObjective(nlp,[],export_path);

solver = IpoptApplication(nlp);

tic
[sol, info] = solver.optimize;
toc

[tspan, states, inputs, params] = exportSolution(nlp, sol);