addpath('../../matlab/');
addpath('export/');

setup_default_path;

nlp = NonlinearProgram('ex051','withHessian',true);

nlp = addVariable(nlp,'x',3);
nlp = addVariable(nlp,'y',2);

nlp = genVarIndices(nlp);

nlp = addCost(nlp,'cost1',{'x'});
nlp = addCost(nlp,'cost2',{'x'});
nlp = addCost(nlp,'cost3',{'y'});


nlp = addConstraint(nlp,'constr1',{'x'},1,4,4);
nlp = addConstraint(nlp,'constr2',{'x','y'},1,0,0);
nlp = addConstraint(nlp,'constr3',{'x','y'},1,0,0);


nlp = setInitialGuess(nlp,[ 2.5 0.5 2 -1 0.5 ]);


extraOpts.fixed_variable_treatment = 'RELAX_BOUNDS';
extraOpts.point_perturbation_radius = 0;
extraOpts.derivative_test = 'second-order';
extraOpts.derivative_test_perturbation = 1e-8;

solver = IpoptApplication(nlp, extraOpts);

solver = initialize(solver);

solver = solver.optimize
