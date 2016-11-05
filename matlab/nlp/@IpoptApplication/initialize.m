function obj = initialize(obj)
    % This function initialize the NLP problem for the particular NLP
    % solver, including group different types of constraints, index cost
    % functions and constraints, etc.
    %
    % @note We assume that all optimization variables, cost functions and
    % constraints have been registered (added) with the NonlinearProgram
    % object 'nlp'. 
    % 
    % @see NonlinearProgram
    %
    % Parameters:
    %  nlp: The nonlinear program to be solved @type NonlinearProgram
    
    nlp = obj.nlp;
    
    % get the NLP variables information
    [obj.dimVariable, obj.lb, obj.ub] = getVarInfo(nlp);
    
    %% initialize cost function array
    obj.costArray   = indexCostArray(obj);
    
    nCosts  = numel(obj.costArray);
    obj.nnzGrad = sum([obj.costArray.nnzJac]);
    
    obj.gradNonzeroIndex = ones(obj.nnzGrad,2);
    
    for i=1:nCosts
        cost = obj.costArray(i);
        
        % get the sparsity structure (i.e., the indices of non-zero elements)
        % of the Jacobian of the current function
        jac_struct = cost.jac_struct;
        
        % retrieve the indices of non-zero Jacobian elements of the current
        % function
        j_index = cost.j_index;
        
        % retrieve the indices of dependent variables 
        dep_indices = cost.deps;
        
        %| @note The row index are always 1, because the cost function is a
        % scalar function.
        %| @note The jac_struct gives the indices of non-zero Jacobian
        % elements of the current function. 
        obj.gradNonzeroIndex(j_index,2) = dep_indices(jac_struct(:,2));
    end
    
    
    %% initialize constraint array
    obj.constrArray = indexConstraintArray(obj);
    
    % dimension of the entire constraints vector
    obj.dimConstraint = sum([obj.constrArray.dims]);
    
    % number of non-zero elements in the Jacobian matrix
    obj.nnzJac = sum([obj.constrArray.nnzJac]);
    
    % pre-allocation
    obj.jacNonzeroIndex = ones(obj.nnzJac,2);
    obj.cl = zeros(obj.dimConstraint,1);
    obj.cu = zeros(obj.dimConstraint,1);
    
    nConstr  = numel(obj.constrArray);
    for i=1:nConstr
        constr = obj.constrArray(i);
        
        % sparse structure of the Jacobian matrix
        jac_struct = constr.jac_struct;
        % get indices of the constraint
        c_index = constr.c_index;
        % get jacobian entry indices
        j_index = constr.j_index;
        % get indices of dependent variables
        dep_indices = constr.deps;
        
        % row indices of non-zero entries
        obj.jacNonzeroIndex(j_index,1) = c_index(jac_struct(:,1));
        % column indices of non-zero entries
        obj.jacNonzeroIndex(j_index,2) = dep_indices(jac_struct(:,2));
        
        
        obj.cl(c_index,1) = constr.cl;
        obj.cu(c_index,1) = constr.cu;
    end
    
    
    
    %% If using user-defined Hessian functions
    
    if nlp.options.withHessian
        nnzCostHess = sum([obj.costArray.nnzHess]);
        
        hessCostNonzeroIndex = ones(nnzCostHess,2);
        
        for i=1:nCosts
            cost = obj.costArray(i);
            % sparse structure of the Hessian matrix
            hess_struct = cost.hess_struct;
            % get indices of non-zero entries of Hessian matrix
            h_index = cost.h_index;
            % get indices of dependent variables
            dep_indices = cost.deps;
            
            if ~cost.is_linear
                hessCostNonzeroIndex(h_index,1) = dep_indices(hess_struct(:,1));
                hessCostNonzeroIndex(h_index,2) = dep_indices(hess_struct(:,2));
            end
        end
        
        
        nnzConstrHess = sum([obj.constrArray.nnzHess]);
        hessConstrNonzeroIndex = ones(nnzConstrHess,2);
        
        for i=1:nConstr
            constr = obj.constrArray(i);
            
            % sparse structure of the Hessian matrix
            hess_struct = constr.hess_struct;
            % get indices of non-zero entries of Hessian matrix
            h_index = constr.h_index;
            % get indices of dependent variables
            dep_indices = constr.deps;
            
            if ~constr.is_linear
                hessConstrNonzeroIndex(h_index,1) = dep_indices(hess_struct(:,1));
                hessConstrNonzeroIndex(h_index,2) = dep_indices(hess_struct(:,2));
            end
        end
        
        obj.nnzHess = nnzCostHess + nnzConstrHess;
        obj.hessNonzeroIndex = [hessCostNonzeroIndex;hessConstrNonzeroIndex];
    else
        obj.nnzHess = [];
        obj.hessNonzeroIndex = [];
    end
end