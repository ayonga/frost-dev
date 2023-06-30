%% Initialize the workspace and frost paths:
clear; clc;
restoredefaultpath;
addpath('../../');
frost_addpath();
addpath(genpath("model"));
export_path = 'gen/';
%%
[rabbit, rabbit_1step] = load_model('urdf/five_link_walker.urdf');

%% Create trajectory optimization NLP problem
nlp = load_problem(rabbit_1step);

%% Compile symbolic expressions to C source code and mex libraries.
COMPILE = 1;

if COMPILE
    if ~isfolder([export_path, 'opt/'])
        mkdir([export_path, 'opt/'])
    end
    compileConstraint(nlp,[],[],[export_path, 'opt/']);
    compileObjective(nlp,[],[],[export_path, 'opt/']);
    if ~isfolder([export_path, 'sim/'])
        mkdir([export_path, 'sim/'])
    end
    compile(rabbit_1step,[export_path, 'sim/']);
    export(rabbit_1step.Gamma.Nodes.Domain{1}.VirtualConstraints.Outputs, [export_path, 'sim/']);

    if ~isfolder([export_path, 'sym/'])
        mkdir([export_path, 'sym/'])
    end
    rabbit_1step.saveExpression('gen/sym');
end
%% Run the optimization using IPOPT
addpath([export_path, 'opt/']);
nlp.update;
opts.linear_solver = 'ma57';
% opts.derivative_test = 'second-order';
% opts.derivative_test_tol = 1e-3;
% opts.max_iter = 96;
solver = IpoptApplication(nlp, opts);
x0 = nlp.getInitialGuess('typical');
% Run Optimization
tic
% old = load('x0');
% [sol, info] = optimize(solver, old.sol);
[sol, info] = optimize(solver,x0);
toc
[tspan, states, inputs, params] = exportSolution(nlp, sol);
gait = struct(...
    'tspan',tspan,...
    'states',states,...
    'inputs',inputs,...
    'params',params);


%% Animate/Plot
addpath('plot/');
addpath('gen/sim');
anim = LoadAnimator(rabbit,gait,'SkipExporting',true,'ExportPath','gen/sim');
