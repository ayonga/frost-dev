function obj = optimize(obj)
    % This function runs the solver's optimization routine for the
    % NLP
    %
    % Be sure the run the initialization procedure before run this
    % function.
    
    x0 = getStartingPoint(obj.nlp);
    
    opts = obj.options;
    opts.lb = obj.lb;
    opts.ub = obj.ub;
    opts.cl = obj.cl;
    opts.cu = obj.cu;
    
    funcs = struct();
    funcs.objective         = @(x)IpoptObjective(x, obj.costArray);
    funcs.constraints       = @(x)IpoptConstraints(x, obj.constrArray, obj.dimConstraint);
    funcs.gradient          = @(x)IpoptGradient(x, obj.costArray, obj.dimVariable, obj.nnzGrad, ...
        obj.gradNonzeroIndex);
    funcs.jacobian          = @(x)IpoptJacobian(x, obj.constrArray, obj.dimConstraint, obj.dimVariable, ...
        obj.nnzJac, obj.jacNonzeroIndex);
    funcs.jacobianstructure = @()IpoptJacobianStructure(obj.dimConstraint, obj.dimVariable, ...
        obj.nnzJac, obj.jacNonzeroIndex);
    
    if strcmpi(opts.ipopt.hessian_approximation, 'exact')
        assert(obj.nlp.options.withHessian,...
            ['The NLP has no user definied Hessian function associated.\n',...
            'Please do not enable exact hessian option']);
        funcs.hessian           = @(x, sigma, lambda)IpoptHessian(x, sigma, lambda, ...
            obj.costArray, obj.constrArray, obj.dimVariable, ...
            obj.nnzHess, obj.hessNonzeroIndex);
        funcs.hessianstructure  = @()IpoptHessianStructure(obj.dimVariable, ...
            obj.nnzHess, obj.hessNonzeroIndex);
    end
    
    
    [x, info] = ipopt(x0, funcs, opts);
    
    obj.sol = x;
    obj.info = info;
    
    %% cost function
    function f = IpoptObjective(x, costArray)
        % objective function of ipopt NLP problem
        nCosts = numel(costArray);
        f = 0;
        for i = 1:nCosts
            costs = costArray(i);
            var = x(costs.deps); % dependent variables
            
            % calculate cost value
            f = f + costs.f(var);
            
        end
    end
    %%
    
    
    %% constraints
    function [C] = IpoptConstraints(x, constrArray, dimConstraint)
        % nonlinear constraints of the optimization problem
        
        nConstr = numel(constrArray);
        
        % preallocation
        C   = zeros(dimConstraint,1);
        for i = 1:nConstr
            constr = constrArray(i);
            var = x(constr.deps); % dependent variables
            
            % calculate constraints value
            C(constr.c_index) = constr.f(var);
            
        end
        
    end
    %%
    
    %% Objective gradient function
    function [J] = IpoptGradient(x, costArray, dimVariable, nnzGrad, gradNonzeroIndex)
        % Gradient of the objective function of the optimization problem
        
        
        nCosts = numel(costArray);
        %     nzmaxCost = numel(costRows);
        
        % preallocation
        J_val   = zeros(nnzGrad,1);
        for i = 1:nCosts
            constr = costArray(i);
            var = x(constr.deps); % dependent variables
            
            % calculate constraints value
            J_val(constr.j_index) = constr.jac(var);
            
            
        end
        
        J = sparse2(gradNonzeroIndex(:,1),gradNonzeroIndex(:,2),...
            J_val, 1, dimVariable, nnzGrad);
        
    end
    %%
    
    %% constraints Jacobian
    function [J] = IpoptJacobian(x, constrArray, dimConstraint, dimVariable, nnzJac, jacNonzeroIndex)
        % jacobian matrix nonlinear constraints of the optimization problem
        
        nConstr = numel(constrArray);
        
        % preallocation
        J_val   = zeros(nnzJac,1);
        for i = 1:nConstr
            constr = constrArray(i);
            var = x(constr.deps); % dependent variables
            
            % calculate constraints value
            J_val(constr.j_index) = constr.jac(var);
            
            
        end
        
        J = sparse2(jacNonzeroIndex(:,1), jacNonzeroIndex(:,2),...
             J_val, dimConstraint, dimVariable, nnzJac);
        
    end
    %%
    
    %% constraints Jacobian structure
    function [J] = IpoptJacobianStructure(dimConstraint, dimVariable, nnzJac, jacNonzeroIndex)
        % jacobian structure of constraints of the optimization problem
        
        
        % preallocation
        J_val   = ones(nnzJac,1);
        
        J = sparse2(jacNonzeroIndex(:,1), jacNonzeroIndex(:,2),...
             J_val, dimConstraint, dimVariable, nnzJac);
        
    end
    %%
    
    %% Hessian
    function [H_ret] = IpoptHessian(x, sigma, lambda, ...
            costArray, constrArray, dimVariable, nnzHess, hessNonzeroIndex)
        % compute hessian matrix of the optimization problem
        
        
        
        nConstr   = numel(constrArray);
        nCost     = numel(costArray);
        % preallocation
        H_val   = zeros(nnzHess,1);
        
        
        
        for i = 1:nCost
            cost   = costArray(i);
            if ~cost.is_linear
                var      = x(cost.deps); % dependent variables
                % calculate constraints value
                H_val(cost.h_index) = cost.hess(var,sigma);
            end
            nnzCostHess = cost.h_index(end);
        end
        
        
        
        for i = 1:nConstr
            constr   = constrArray(i);
            if ~constr.is_linear
                var      = x(constr.deps); % dependent variables
                lambda_i = lambda(constr.c_index);
                % calculate constraints value
                H_val(constr.h_index + nnzCostHess) = constr.hess(var,lambda_i);
            end
            
        end
          
        
        H_ret = sparse2(hessNonzeroIndex(:,1),hessNonzeroIndex(:,2),...
            H_val, dimVariable, dimVariable, nnzHess);
    end
    %%
    
    %%
    function [H_ret] = IpoptHessianStructure(dimVariable, nnzHess, hessNonzeroIndex)
        % hessian structure of the optimization problem
        
        %     nConstr = numel(constrArray);
        %     nzmaxConstr = numel(jacRows);
        
        % preallocation
        H_val   = ones(nnzHess,1);
        
        
        H_ret = sparse2(hessNonzeroIndex(:,1), hessNonzeroIndex(:,2), H_val,...
            dimVariable, dimVariable, nnzHess);
        
    end
    %%
end