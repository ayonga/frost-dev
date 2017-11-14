
function nlp = commonConstraints(nlp, bounds, varargin)
%% add constraints
    
    plant = nlp.Plant;
    
        
    % relative degree 2 outputs
    % imposing this constraint is very important for getting the apos
    % matrix correct
    plant.VirtualConstraints.pos.imposeNLPConstraint(nlp, [bounds.pos.kp,bounds.pos.kd], [1,1]);
    
    %%
%     %% end node constraints for outputs
%     x = plant.States.x;
%     t = SymVariable('t');
%     T  = SymVariable('t',[2,1]);
%     
%     tsubs = T(2);
%     virtualcons = plant.VirtualConstraints.pos;
%     ya = virtualcons.ActualFuncs;
%     yd = virtualcons.DesiredFuncs;
% 
%     a_var = SymVariable(tomatrix(virtualcons.OutputParams(:)));
%     
%     y = ya{1} - yd{1};
%     y = subs(y,t,tsubs);
% 
%         
%     output_cons_func = SymFunction('OutputCons_LR',y,{x,a_var,T});
%     vars = nlp.OptVarTable;
%     output_constraints = struct();
%     output_constraints.Name = 'OutputCons_LR';
%     output_constraints.Dimension = 6;
%     output_constraints.lb = 0;
%     output_constraints.ub = 0;
%     output_constraints.SymFun = output_cons_func;
%     output_constraints.DepVariables = [vars.x(nlp.NumNode);...
%                                 vars.apos(nlp.NumNode);...
%                                 vars.T(1)];

%     addConstraint(nlp,output_constraints.Name,'last',output_constraints);
    
    %% Costs are added here
    nlp = ConfigureCollisionConstraints(nlp);
        
%     w = SymVariable('w',[2,1]);
    w = SymVariable('w');
    
    u = plant.Inputs.Control.u;
    
%     % only control input u
%     u2r = tovector(norm(u).^2);
%     u2r_fun = SymFunction(['torque_' plant.Name],u2r,{u});
%     addRunningCost(nlp,u2r_fun,{'u'});
    
    % control input u and collision variable w
    u2r_w = tovector(norm(u).^2) - tovector(w.^2) + 100*w;
    u2r_wfun = SymFunction(['torquew_' plant.Name],u2r_w,{u,w});
    addRunningCost(nlp,u2r_wfun,{'u','w'});

    % only collision variable
%     w2r   = tovector(w(1)*w(2));
%     w2r_fun = SymFunction(['wcost_' plant.Name],w2r,{w});
%     addRunningCost(nlp,w2r_fun,{'w'});
    
end