% funcs = [nlp.Phase(1).ConstrTable.dynamics_equation(1).SummandFunctions(end-2:end);
%     nlp.Phase(3).ConstrTable.dynamics_equation(1).SummandFunctions(end-2:end)];
% for i=1:length(funcs)
%     fun = funcs(i);
%     export(fun.SymFun,export_path);
%     exportJacobian(fun.SymFun,export_path);
% end
% 
% 
% compileConstraint(nlp,[1,3],{'pfourBarCont','h_fourBar_cassie','dh_fourBar_cassie','ddh_fourBar_cassie'},export_path);
% compileConstraint(nlp,2,'dxDiscreteMapLeftImpact',export_path);
% compileConstraint(nlp,4,'dxDiscreteMapRightImpact',export_path);
% compileConstraint(nlp,'RightStance',{'y_output_RightStance'
%     'd1y_output_RightStance'
%     'output_output_dynamics'
%     'swing_yaw_RightStance'},export_path);
% compileConstraint(nlp,'RightStance',{...
%     'step_distance_RightStance'},export_path);