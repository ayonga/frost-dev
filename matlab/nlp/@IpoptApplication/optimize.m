function obj = optimize(obj)
    % This function runs the solver's optimization routine for the
    % NLP
    %
    
    x0 = getStartingPoint(obj.nlp);
    
    opts = obj.options;
    
    
    [dimOptVar, lb, ub] = getVarInfos(obj.nlp);
    [costArray, costInfos] ...
        = getCostInfos(obj.nlp);
    [constrArray, constrInfos] ...
        = getConstrInfos(obj.nlp, 'ipopt');
    
    
    opts.lb = lb;
    opts.ub = ub;
    opts.cl = constrInfos.cl;
    opts.cu = constrInfos.cu;
    
    funcs = struct();
    funcs.objective         = @(x)IpoptObjective(x, costArray);
    funcs.constraints       = @(x)IpoptConstraints(x, constrArray, constrInfos.dimConstr);
    funcs.gradient          = @(x)IpoptGradient(x, costArray, dimOptVar, costInfos.nnzGrad, ...
        costInfos.gradSparseIndices);
    funcs.jacobian          = @(x)IpoptJacobian(x, constrArray, constrInfos.dimConstr, dimOptVar, ...
        constrInfos.nnzJac, constrInfos.jacSparseIndices);
    funcs.jacobianstructure = @()IpoptJacobianStructure(constrInfos.dimConstr, dimOptVar, ...
        constrInfos.nnzJac, constrInfos.jacSparseIndices);
    
    if strcmpi(opts.ipopt.hessian_approximation, 'exact')
        assert(obj.nlp.options.withHessian,...
            ['The NLP has no user definied Hessian function associated.\n',...
            'Please do not enable exact hessian option']);
        funcs.hessian           = @(x, sigma, lambda)IpoptHessian(x, sigma, lambda, ...
            costArray, constrArray, dimOptVar, costInfos.nnzCostHess, costInfos.costHessSparseIndices,...
            constrInfos.nnzConstrHess, constrInfos.constrHessSparseIndices);
        funcs.hessianstructure  = @()IpoptHessianStructure(dimOptVar, ...
            costInfos.nnzCostHess, costInfos.costHessSparseIndices,...
            constrInfos.nnzConstrHess, constrInfos.constrHessSparseIndices);
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
    function [C] = IpoptConstraints(x, constrArray, dimConstr)
        % nonlinear constraints of the optimization problem
        
        nConstr = numel(constrArray);
        
        % preallocation
        C   = zeros(dimConstr,1);
        for i = 1:nConstr
            constr = constrArray(i);
            var = x(constr.deps); % dependent variables
            
            % calculate constraints value
            C(constr.c_index) = constr.f(var);
            
        end
        
    end
    %%
    
    %% Objective gradient function
    function [J] = IpoptGradient(x, costArray, dimOptVar, nnzGrad, gradSparseIndices)
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
        
        J = sparse2(gradSparseIndices(:,1),gradSparseIndices(:,2),...
            J_val, 1, dimOptVar, nnzGrad);
        
    end
    %%
    
    %% constraints Jacobian
    function [J] = IpoptJacobian(x, constrArray, dimConstr, dimOptVar, nnzJac, jacSparseIndices)
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
        
        J = sparse2(jacSparseIndices(:,1), jacSparseIndices(:,2),...
             J_val, dimConstr, dimOptVar, nnzJac);
        
    end
    %%
    
    %% constraints Jacobian structure
    function [J] = IpoptJacobianStructure(dimConstr, dimOptVar, nnzJac, jacSparseIndices)
        % jacobian structure of constraints of the optimization problem
        
        
        % preallocation
        J_val   = ones(nnzJac,1);
        
        J = sparse2(jacSparseIndices(:,1), jacSparseIndices(:,2),...
             J_val, dimConstr, dimOptVar, nnzJac);
        
    end
    %%
    
    %% Hessian
    function [H_ret] = IpoptHessian(x, sigma, lambda, ...
            costArray, constrArray, dimOptVar, nnzCostHess, costHessSparseIndices,...
            nnzConstrHess, constrHessSparseIndices)
        % compute hessian matrix of the optimization problem
        
        
        
        nConstr   = numel(constrArray);
        nCost     = numel(costArray);
        % preallocation
        H_cost_val   = zeros(nnzCostHess,1);
        H_constr_val   = zeros(nnzConstrHess,1);
        
        
        
        for i = 1:nCost
            cost   = costArray(i);
            if ~cost.is_linear
                var      = x(cost.deps); % dependent variables
                % calculate constraints value
                H_cost_val(cost.h_index) = cost.hess(var,sigma);
            end
            
        end
        H_cost = sparse2(costHessSparseIndices(:,1),costHessSparseIndices(:,2),...
            H_cost_val, dimOptVar, dimOptVar, nnzCostHess);
        
        for i = 1:nConstr
            constr   = constrArray(i);
            if ~constr.is_linear
                var      = x(constr.deps); % dependent variables
                lambda_i = lambda(constr.c_index);
                % calculate constraints value
                H_constr_val(constr.h_index) = constr.hess(var,lambda_i);
            end
            
        end
        
        H_constr = sparse2(constrHessSparseIndices(:,1),constrHessSparseIndices(:,2),...
            H_constr_val, dimOptVar, dimOptVar, nnzConstrHess);
        
        
        H_ret = H_cost + H_constr;
    end
    %%
    
    %%
    function [H_ret] = IpoptHessianStructure(dimOptVar, nnzCostHess, costHessSparseIndices,...
            nnzConstrHess, constrHessSparseIndices)
        % hessian structure of the optimization problem
        
        %     nConstr = numel(constrArray);
        %     nzmaxConstr = numel(jacRows);
        
        % preallocation
        H_val   = ones(nnzCostHess + nnzConstrHess,1);
        
        
        hess_struct = [costHessSparseIndices;constrHessSparseIndices];
        H_ret = sparse2(hess_struct(:,1), hess_struct(:,2), H_val,...
            dimOptVar, dimOptVar, nnzCostHess + nnzConstrHess);
        
    end
    %%
end