function obj = addDynamicsConstraint(obj)
    % Add system dynamics equations as a set of equality constraints   
    %
    % The full dynamics equations consist of two parts, the
    % Euler-Langrangian dynamics of the rigid body model and the holonomic
    % constraints of the system:
    % \f{eqnarray*}{
    %  D(q)*\ddot{q} + C(q,\dot{q}) + G(q) - Be*u - J^T(q)*Fe &= 0 \\
    %  J(q)*\ddot{q} + \dot{J}(q,\dot{q})*\dot{q} &= 0
    % \f}
    %

    % basic information of NLP decision variables
    nNode  = obj.NumNode;
    vars   = obj.OptVarTable;
    plant  = obj.Plant;
    nState = plant.numState;
    
    
    ceq_err_bound = obj.Options.EqualityConstraintBoundary;
    
    fx = plant.dynamicalConstraints();
    
    funcs = fieldnames(fx);
    
    node_list = 1:1:nNode;
    f_cstr = cell(numel(funcs),1);
    
    for j=1:numel(funcs)
        fun = fx.(funcs{j});
        fx_cstr = struct();
        fx_cstr(numel(node_list)) = struct(); 
        [fx_cstr.Dimension] = deal(nState);
        [fx_cstr.Name] = deal(fun.Name);
        [fx_cstr.SymFun] = deal(fun);
        
        switch funcs{j}
            case 'mass_matrix'
                for i=1:numel(node_list)
                    idx = node_list(i);
                    if isa(plant,'SecondOrderSystem')
                        fx_cstr(i).DepVariables = [vars.x(idx);vars.ddx(idx)];
                    else
                        fx_cstr(i).DepVariables = [vars.x(idx);vars.dx(idx)];
                    end
                end
            case 'control_input'
                for i=1:numel(node_list)
                    idx = node_list(i);
                    fx_cstr(i).DepVariables = [vars.x(idx);vars.u(idx)];
                    
                end
            case 'external_input'
                for i=1:numel(node_list)
                    idx = node_list(i);
                    fx_cstr(i).DepVariables = [vars.x(idx);vars.f(idx)];
                    
                end
            otherwise
                for i=1:numel(node_list)
                    idx = node_list(i);
                    fx_cstr(i).DepVariables = [vars.x(idx);vars.dx(idx)];
                    
                end
        end
        
                
        f_cstr{j} = fx_cstr;
    end
    
    
    dynamics(numel(node_list)) = struct(); 
    [dynamics.Dimension] = deal(nState);
    [dynamics.Name] = deal(['dynamics_' plant.Name]);
    [dynamics.lb] = deal(ceq_err_bound);
    [dynamics.ub] = deal(ceq_err_bound);
    [dynamics.Type] = deal('Nonlinear');
    for i=1:numel(node_list)
        dep_func = cell(numel(funcs),1);
        for j=1:numel(funcs)
            dep_func{j} = NlpFunction(f_cstr{j}(i));
        end
        
        dynamics(i).DependentFuncs = dep_func;
        
        
    end
    obj = addConstraint(obj,'dynamics','all',dynamics);
    
end
