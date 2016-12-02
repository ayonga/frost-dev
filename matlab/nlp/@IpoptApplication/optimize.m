function [sol, info] = optimize(obj, nlp)
    % This function runs the solver's optimization routine for the
    % NLP
    %
    % Be sure the run the initialization procedure before run this
    % function.
    
    
    % get the information of NLP variables 
    [dimVars, lb, ub] = getVarInfo(nlp);
    
    % get the initial guess 
    x0 = getInitialGuess(nlp, obj.options.initialguess);
    
    opts = struct;
    opts.lb = lb;
    opts.ub = ub;
    opts.cl = obj.constraint.cl;
    opts.cu = obj.constraint.cu;
    opts.ipopt = obj.options.ipopt;
    
    funcs = struct();
    funcs.objective         = @(x)IpoptObjective(x, obj.objective);
    funcs.constraints       = @(x)IpoptConstraints(x, obj.constraint);
    funcs.gradient          = @(x)IpoptGradient(x, obj.objective, dimVars);
    funcs.jacobian          = @(x)IpoptJacobian(x, obj.constraint, dimVars);
    funcs.jacobianstructure = @()IpoptJacobianStructure(obj.constraint, dimVars);
    
    if strcmpi(opts.ipopt.hessian_approximation, 'exact')
        
        funcs.hessian           = @(x, sigma, lambda)IpoptHessian(x, sigma, lambda, ...
            obj.objective, obj.constraint, dimVars);
        funcs.hessianstructure  = @()IpoptHessianStructure(obj.objective, ...
            obj.constraint, dimVars);
    else
        
    end
    
    
    [sol, info] = ipopt(x0, funcs, opts);
    
    
    
    %% objective function
    function f = IpoptObjective(x, objective)
        % nested function that commputes the objective function of the
        % NLP problem
        %
        % Parameters:
        %  objective: a structure of arrays that contains the information
        %  of all subfunction of the objective.
        
        f = 0;
        for i = 1:objective.num_funcs
            var = x(objective.dep_indices{i}); % dependent variables
            
            % calculate cost value
            if isempty(objective.auxdata{i})
                f = f + feval(objective.funcs{i}, var);
            else
                f = f + feval(objective.funcs{i}, var, objective.auxdata{i});
            end
            
        end
    end
    %%
    
    
    %% constraints
    function [C] = IpoptConstraints(x, constraint)
        % nested function that commputes the constraints of the NLP problem
        %
        % Parameters:
        %  constraint: a structure of arrays that contains the information
        %  of all constraints
        
        
        % preallocation
        C   = zeros(constraint.dimension,1);
        for i = 1:constraint.num_funcs
            var = x(constraint.dep_indices{i}); % dependent variables
            
            % calculate constraints
            if isempty(constraint.auxdata{i})
                C(constraint.constrIndices{i}) = feval(constraint.funcs{i}, var);
            else
                C(constraint.constrIndices{i})  = feval(constraint.funcs{i}, var, constraint.auxdata{i});
            end
        end
        
    end
    %%
    
    %% Objective gradient function
    function [J] = IpoptGradient(x, objective, dimVars)
        % nested function that commputes the first-order derivatives
        % (gradient) of the objective function of the NLP problem
        %
        % Parameters:
        %  objective: a structure of arrays that contains the information
        %  of all subfunction of the objective.
        %  dimVars: the dimension of the NLP variables
        
        
        
        % preallocation
        J_val   = zeros(objective.nnz_jac,1);
        for i = 1:objective.num_funcs
            var = x(objective.dep_indices{i});% dependent variables
            
            % calculate gradient
            if isempty(objective.auxdata{i})
                J_val(objective.nz_jac_indices{i}) = feval(objective.jac_funcs{i}, var);
            else
                J_val(objective.nz_jac_indices{i}) = feval(objective.jac_funcs{i}, var, objective.auxdata{i});
            end
            
        end
        
        % construct the sparse jacobian matrix
        J = sparse2(objective.nz_jac_rows, objective.nz_jac_cols,...
            J_val, 1, dimVars, objective.nnz_jac);
        
    end
    %%
    
    %% constraints Jacobian
    function [J] = IpoptJacobian(x, constraint, dimVars)
        % nested function that commputes the first-order derivatives
        % (Jacobian) of the constraints of the NLP problem
        %
        % Parameters:
        %  constraint: a structure of arrays that contains the information
        %  of all constraints
        %  dimVars: the dimension of the NLP variables
        
        % preallocation
        J_val   = zeros(constraint.nnz_jac,1);
        for i = 1:constraint.num_funcs
            var = x(constraint.dep_indices{i});% dependent variables
            
            % calculate Jacobian
            if isempty(constraint.auxdata{i})
                J_val(constraint.nz_jac_indices{i}) = feval(constraint.jac_funcs{i}, var);
            else
                J_val(constraint.nz_jac_indices{i}) = feval(constraint.jac_funcs{i}, var, constraint.auxdata{i});
            end
            
        end
        
        % construct the sparse jacobian matrix
        J = sparse2(constraint.nz_jac_rows, constraint.nz_jac_cols,...
            J_val, constraint.dimension, dimVars, constraint.nnz_jac);
        
    end
    %%
    
    %% constraints Jacobian structure
    function [J] = IpoptJacobianStructure(constraint, dimVars)
        % nested function that commputes the sparsity structure of the
        % first-order derivatives (Jacobian) of the constraints of the NLP
        % problem
        %
        % Parameters:
        %  constraint: a structure of arrays that contains the information
        %  of all constraints
        %  dimVars: the dimension of the NLP variables
        
        
        J = sparse2(constraint.nz_jac_rows, constraint.nz_jac_cols,...
            ones(constraint.nnz_jac,1), constraint.dimension, ...
            dimVars, constraint.nnz_jac);
        
    end
    %%
    
    %% Hessian
    function [H_ret] = IpoptHessian(x, sigma, lambda, ...
            objective, constraint, dimVars)
        % nested function that commputes the second-order derivatives
        % (Hessian) of the Lagrangian of the NLP problem
        %
        % Parameters:
        %  objective: a structure of arrays that contains the information
        %  of all subfunction of the objective.
        %  constraint: a structure of arrays that contains the information
        %  of all constraints
        %  dimVars: the dimension of the NLP variables
        
        
        
        % preallocation
        hes_objective   = zeros(objective.nnz_hess,1);
        
        % compute the Hessian for objective function
        for i = 1:objective.num_funcs
            var = x(objective.dep_indices{i});% dependent variables
            
            if ~isempty(objective.nz_hess_indices{i})
                % if the function is a linear function, then the Hessian of
                % such function is zero. In other words, the non-zero
                % indices should be empty.
                if isempty(objective.auxdata{i})
                    hes_objective(objective.nz_hess_indices{i}) = feval(objective.hess_funcs{i}, var, sigma);
                else
                    hes_objective(objective.nz_hess_indices{i}) = feval(objective.hess_funcs{i}, var, sigma, objective.auxdata{i});
                end
            end
            
        end
        
        H_objective = sparse2(objective.nz_hess_rows,objective.nz_hess_rows,...
            hes_objective, dimVars, dimVars, objective.nnz_hess);
        
        % preallocation
        hes_constr   = zeros(constraint.nnz_hess,1);
        % compute the Hessian for constraints
        for i = 1:constraint.num_funcs
            var = x(constraint.dep_indices{i});% dependent variables
            lambda_i = lambda(constraint.constrIndices{i});
            
            if ~isempty(constraint.nz_hess_indices{i})
                % if the function is a linear function, then the Hessian of
                % such function is zero. In other words, the non-zero
                % indices should be empty.
                if isempty(constraint.auxdata{i})
                    hes_constr(constraint.nz_hess_indices{i}) = feval(constraint.hess_funcs{i}, var, lambda_i);
                else
                    hes_constr(constraint.nz_hess_indices{i}) = feval(constraint.hess_funcs{i}, var, lambda_i, constraint.auxdata{i});
                end
            end
            
        end
        
          
        
        H_constr = sparse2(constraint.nz_hess_rows,constraint.nz_hess_rows,...
            hes_constr, dimVars, dimVars, constraint.nnz_hess);
        
        
        H_ret = H_objective + H_constr;
    end
    %%
    
    %%
    function [H_ret] = IpoptHessianStructure(objective, constraint, dimVars)
        % nested function that returns the sparsity structure of the
        % second-order derivatives (Hessian) of the Lagrangian of the NLP
        % problem
        %
        % Parameters:
        %  objective: a structure of arrays that contains the information
        %  of all subfunction of the objective.
        %  constraint: a structure of arrays that contains the information
        %  of all constraints
        %  dimVars: the dimension of the NLP variables
        
        
        H_objective = sparse2(objective.nz_hess_rows,objective.nz_hess_rows,...
            ones(objective.nnz_hess,1), dimVars, dimVars, objective.nnz_hess);
        
        
        H_constr = sparse2(constraint.nz_hess_rows,constraint.nz_hess_rows,...
            ones(constraint.nnz_hess,1), dimVars, dimVars, constraint.nnz_hess);
        
        
        H_ret = H_objective + H_constr;
        
    end
    %%
end