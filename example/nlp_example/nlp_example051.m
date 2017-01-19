addpath('../..');
addpath('export/');

matlab_setup;


options.DerivativeLevel = 1;
nlp = NonlinearProgram(options);


x = NlpVariable('Name', 'x', 'Dimension', 3, ...
    'lb', -inf, 'ub', inf, 'x0', [2.5 0.5 2]);
y = NlpVariable('Name', 'y', 'Dimension', 2, ...
    'lb', -inf, 'ub', inf, 'x0', [-1 0.5]);
nlp = addVariable(nlp,x);
nlp = addVariable(nlp,y);

nlp = genVarIndices(nlp);

costs(1) = NlpFunction('Name', 'f_cost1', 'Type', 'nonlinear');
costs(1) = setDependent(costs(1),{x});
js = feval('Js_cost1',0);
costs(1) = setJacobianPattern(costs(1),js,'IndexForm');
costs(1) = setJacobianFunction(costs(1),'J_cost1');
hs = feval('Hs_cost1',0);
costs(1) = setHessianPattern(costs(1),hs,'IndexForm');
costs(1) = setHessianFunction(costs(1),'H_cost1');

costs(2) = NlpFunction('Name', 'f_cost2','Type','nonlinear');
costs(2) = setDependent(costs(2),{x});
js = feval('Js_cost2',0);
costs(2) = setJacobianPattern(costs(2),js,'IndexForm');
costs(2) = setJacobianFunction(costs(2),'J_cost2');
hs = feval('Hs_cost2',0);
costs(2) = setHessianPattern(costs(2),hs,'IndexForm');
costs(2) = setHessianFunction(costs(2),'H_cost2');

costs(3) = NlpFunction('Name','f_cost3','Type','nonlinear');
costs(3) = setDependent(costs(3),{y});
js = feval('Js_cost3',0);
costs(3) = setJacobianPattern(costs(3),js,'IndexForm');
costs(3) = setJacobianFunction(costs(3),'J_cost3');
hs = feval('Hs_cost3',0);
costs(3) = setHessianPattern(costs(3),hs,'IndexForm');
costs(3) = setHessianFunction(costs(3),'H_cost3');

nlp = addObjective(nlp,costs);

constrs(1) = NlpFunction('Name','f_constr1','Type','nonlinear');
constrs(1) = setDependent(constrs(1),{x});
js = feval('Js_constr1',0);
constrs(1) = setJacobianPattern(constrs(1),js,'IndexForm');
constrs(1) = setJacobianFunction(constrs(1),'J_constr1');
hs = feval('Hs_constr1',0);
constrs(1) = setHessianPattern(constrs(1),hs,'IndexForm');
constrs(1) = setHessianFunction(constrs(1),'H_constr1');
constrs(1) = setBoundaryValue(constrs(1),4,4);

constrs(2) = NlpFunction('Name', 'f_constr2', 'Type', 'nonlinear');
constrs(2) = setDependent(constrs(2),{x,y});
js = feval('Js_constr2',0);
constrs(2) = setJacobianPattern(constrs(2),js,'IndexForm');
constrs(2) = setJacobianFunction(constrs(2),'J_constr2');
hs = feval('Hs_constr2',0);
constrs(2) = setHessianPattern(constrs(2),hs,'IndexForm');
constrs(2) = setHessianFunction(constrs(2),'H_constr2');
constrs(2) = setBoundaryValue(constrs(2),0,0);

constrs(3) = NlpFunction('Name', 'f_constr3', 'Type', 'nonlinear');
constrs(3) = setDependent(constrs(3),{x,y});
js = feval('Js_constr3',0);
constrs(3) = setJacobianPattern(constrs(3),js,'IndexForm');
constrs(3) = setJacobianFunction(constrs(3),'J_constr3');
hs = feval('Hs_constr3',0);
constrs(3) = setHessianPattern(constrs(3),hs,'IndexForm');
constrs(3) = setHessianFunction(constrs(3),'H_constr3');
constrs(3) = setBoundaryValue(constrs(3),0,0);

nlp = addConstraint(nlp,constrs);


extraOpts.fixed_variable_treatment = 'RELAX_BOUNDS';
extraOpts.point_perturbation_radius = 0;
extraOpts.jac_c_constant        = 'yes';
extraOpts.hessian_approximation = 'limited-memory';
extraOpts.derivative_test = 'first-order';
extraOpts.derivative_test_perturbation = 1e-7;

solverApp = IpoptApplication(nlp, extraOpts);



[sol, info] = optimize(solverApp, nlp);
