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
    ceq_err_bound = obj.Options.EqualityConstraintBoundary;    
    node_list = 1:1:nNode;
    plant  = obj.Plant;
    numState = plant.numState;
    
    % M(x)dx or M(x)ddx
    if isempty(plant.Mmat)
        if ~isempty(plant.States.ddx)
            ddx = plant.States.ddx;
            MmatDx = SymFunction(['MmatDx_' plant.Name],-ddx,{ddx});
        else
            dx = plant.States.dx;
            MmatDx = SymFunction(['MmatDx_' plant.Name],-dx,{dx});
        end
    else
        x = plant.States.x;
        if ~isempty(plant.States.ddx)
            ddx = plant.States.ddx;
            MmatDx = SymFunction(['MmatDx_' plant.Name],-plant.Mmat*ddx,{x,ddx});
        else
            dx = plant.States.dx;
            MmatDx = SymFunction(['MmatDx_' plant.Name],-plant.Mmat*dx,{x,dx});
        end
    end    
    
    mdx_cstr_fun(nNode) = NlpFunction();   % preallocation
    if ~isempty(plant.States.ddx)%second order system
        for i=node_list
            mdx_cstr_fun(i) = NlpFunction('Name','MmatDx',...
                'Dimension',numState,'SymFun',MmatDx,...
                'DepVariables',[vars.x(i);vars.ddx(i)]);
        end
    else                         %first order system
        for i=node_list
            mdx_cstr_fun(i) = NlpFunction('Name','MmatDx',...
                'Dimension',numState,'SymFun',MmatDx,...
                'DepVariables',[vars.x(i);vars.dx(i)]);
        end
    end
    
    % drift vector fields vf(x)
    n_vf = numel(plant.Fvec);
    Fvec_cstr_fun(n_vf,nNode) = NlpFunction(); % preallocation
    if ~isempty(plant.States.ddx)%second order system
        for i=node_list
            for j=1:n_vf
                Fvec_cstr_fun(j,i) = NlpFunction('Name',plant.Fvec{j}.Name,...
                    'Dimension',numState,'SymFun',plant.Fvec{j},...
                    'DepVariables',[vars.x(i);vars.dx(i)]);
            end
        end
    else                         %first order system
        for i=node_list
            for j=1:n_vf
                Fvec_cstr_fun(j,i) = NlpFunction('Name',plant.Fvec{j}.Name,...
                    'Dimension',numState,'SymFun',plant.Fvec{j},...
                    'DepVariables',[vars.x(i)]);
            end
        end
    end
    
    
    % external input vector fields
    input_names = fieldnames(plant.Inputs);
    n_inputs = numel(input_names);
    Gvec_cstr_fun(n_inputs,nNode) = NlpFunction(); % preallocation
    for i=node_list
        for j=1:n_inputs
            input = input_names{j};
            Gvec_cstr_fun(j,i) = NlpFunction('Name',plant.Gvec.(input).Name,...
                'Dimension',numState,'SymFun',plant.Gvec.(input),...
                'DepVariables',[vars.x(i);vars.(input)(i)]);
        end
    end
        
    % The final dynamic equation constraint is the sum of the above
    % functions
    dynamics_cstr_fun(nNode) = NlpFunction();   % preallocation
    for i=node_list
        dep_funcs = [mdx_cstr_fun(i); % M(x)dx (or M(x)ddx)
            Fvec_cstr_fun(:,i); % Fvec(x) or Fvec(x,dx)
            Gvec_cstr_fun(:,i); % Gvec(x,u)
        ];
            
        dynamics_cstr_fun(i) = NlpFunction('Name','dynamics_equation',...
            'Dimension',numState,'lb',-ceq_err_bound,'ub',ceq_err_bound,...
            'Type','Nonlinear','Summand',dep_funcs);
    end
    
    % add dynamical equation constraints
    obj = addConstraint(obj,'dynamics_equation','all',dynamics_cstr_fun);
    
end
