function obj = initialize(obj, nlp)
    % This function initialize the specific NLP application based on the
    % nonlinear programming problem (specified by 'nlp').
    %
    % The initialization including group different types of constraints,
    % index objective functions and constraints arrays, etc.
    % 
    % @see NonlinearProgram
    %
    % Parameters:
    %  nlp: The NLP problem to be solved @type NonlinearProgram
   
    
    % check the configuration of nlp
    assert(nlp.options.derivative_level >= 1, ...
        'IpoptApplication:derivative_level',...
        ['The order of user-defined derivative functions',... 
        'must be equal or greater than 1.\n']);
    
    
    
    
    %% initialize the objective function
    tmp_objective = struct();
    
    tmp_objective.num_funcs = numel(nlp.objective_array(:));
    tmp_objective.nnz_jac = sum(vertcat(nlp.objective_array(:).nnz_jac));
    
    
    % convert the array of objects into a structure of arrays
    tmp_objective.funcs = {nlp.objective_array(:).name};
    tmp_objective.dep_indices = {nlp.objective_array(:).dep_indices};
    tmp_objective.auxdata = {nlp.objective_array(:).auxdata};
    tmp_objective.jac_funcs = {nlp.objective_array(:).jac_func};   
    
    % preallocate
    tmp_objective.nz_jac_rows = ones(tmp_objective.nnz_jac,1);
    tmp_objective.nz_jac_cols = ones(tmp_objective.nnz_jac,1);
    tmp_objective.nz_jac_indices = cell(tmp_objective.num_funcs,1);
    
    % if user-defined Hessian functions are provided
    if nlp.options.derivative_level == 2         
        tmp_objective.hess_funcs =  {nlp.objective_array(:).hess_func};
        tmp_objective.nnz_hess = sum(vertcat(nlp.objective_array(:).nnz_hess));
        tmp_objective.nz_hess_rows = ones(tmp_objective.nnz_hess,1);
        tmp_objective.nz_hess_cols = ones(tmp_objective.nnz_hess,1);
        tmp_objective.nz_hess_indices = cell(tmp_objective.num_funcs,1);
    end
    
    % initialize offsets of indices to be zero
    jac_index_offset = 0;
    hes_index_offset = 0;
    
    % index the array of objective functions, and configure the sparsity
    % pattern of the derivatives
    for i=1:tmp_objective.num_funcs
        
        jac_index = jac_index_offset + ...
            cumsum(ones(1,nlp.objective_array(i).nnz_jac));
        jac_index_offset = jac_index(end);
        
        % set the indices of non-zero Jacobian elements
        tmp_objective.nz_jac_indices{i} = jac_index;
        
        % get the sparsity pattern (i.e., the indices of non-zero elements)
        % of the Jacobian of the current function
        jac_nz_pattern = nlp.objective_array(i).jac_nz_pattern;
        
        
        % retrieve the indices of dependent variables 
        dep_indices = tmp_objective.dep_indices{i};
        
        %| @note The row index are always 1, because the cost function is a
        % scalar function.
        %| @note The jac_nz_pattern gives the indices of non-zero Jacobian
        % elements of the current function. 
        tmp_objective.nz_jac_cols(jac_index) = dep_indices(jac_nz_pattern.cols);
        
        
        if nlp.options.derivative_level == 2 
            % if user-defined Hessian functions are provided
            hes_index = hes_index_offset + ...
                cumsum(ones(1,nlp.objective_array(i).nnz_hess));
            hes_index_offset = hes_index(end);
            
            % set the indices of non-zero Hessian elements
            tmp_objective.nz_hess_indices{i} = hes_index;
            % get the sparsity pattern (i.e., the indices of non-zero elements)
            % of the Jacobian of the current function
            hess_nz_pattern = nlp.objective_array(i).hess_nz_pattern;
            tmp_objective.nz_hess_rows(hes_index) = dep_indices(hess_nz_pattern.rows);
            tmp_objective.nz_hess_cols(hes_index) = dep_indices(hess_nz_pattern.cols);
        end
    end
    
    obj.objective = tmp_objective;
    
     %% initialize constraints
    tmp_constraint = struct();
    
    tmp_constraint.num_funcs = numel(nlp.constr_array(:));
    tmp_constraint.nnz_jac = sum(vertcat(nlp.constr_array(:).nnz_jac));
    if nlp.options.derivative_level == 2 
        % if user-defined Hessian functions are provided
        tmp_constraint.nnz_hess =  sum(vertcat(nlp.constr_array(:).nnz_jac));
    end
    
    % convert the array of objects into a structure of arrays
    tmp_constraint.funcs = {nlp.constr_array(:).name};
    tmp_constraint.dep_indices = {nlp.constr_array(:).dep_indices};
    tmp_constraint.auxdata = {nlp.constr_array(:).auxdata};
    tmp_constraint.jac_funcs = {nlp.constr_array(:).jac_func};    
    
    % preallocate
    tmp_constraint.nz_jac_rows = ones(tmp_constraint.nnz_jac,1);
    tmp_constraint.nz_jac_cols = ones(tmp_constraint.nnz_jac,1);
    tmp_constraint.constrIndices = cell(tmp_constraint.num_funcs,1);
    tmp_constraint.nz_jac_indices = cell(tmp_constraint.num_funcs,1);
    
    % if user-defined Hessian functions are provided
    if nlp.options.derivative_level == 2         
        tmp_constraint.hess_funcs =  {nlp.constr_array(:).hess_func};
        tmp_constraint.nnz_hess = sum(vertcat(nlp.constr_array(:).nnz_hess));
        tmp_constraint.nz_hess_rows = ones(tmp_constraint.nnz_hess,1);
        tmp_constraint.nz_hess_cols = ones(tmp_constraint.nnz_hess,1);
        tmp_constraint.nz_hess_indices = cell(tmp_constraint.num_funcs,1);
    end
    
    % initialize offsets of indices to be zero
    con_index_offset = 0;
    jac_index_offset = 0;
    hes_index_offset = 0;
    
    % index the array of objective functions, and configure the sparsity
    % pattern of the derivatives
    for i=1:tmp_constraint.num_funcs
        % set the indices of constraints
        con_index = con_index_offset + ...
            cumsum(ones(1,nlp.constr_array(i).dimension));
        con_index_offset = con_index(end);
        tmp_constraint.constrIndices{i} = con_index;
        
        
        % set the indices of non-zero Jacobian elements
        jac_index = jac_index_offset + ...
            cumsum(ones(1,nlp.constr_array(i).nnz_jac));
        jac_index_offset = jac_index(end);
        tmp_constraint.nz_jac_indices{i} = jac_index;
        
        % get the sparsity pattern (i.e., the indices of non-zero elements)
        % of the Jacobian of the current function
        jac_nz_pattern = nlp.constr_array(i).jac_nz_pattern;
        
        
        % retrieve the indices of dependent variables 
        dep_indices = tmp_constraint.dep_indices{i};
        
        
        %| @note The jac_nz_pattern gives the indices of non-zero Jacobian
        % elements of the current function. 
        tmp_constraint.nz_jac_rows(jac_index) = con_index(jac_nz_pattern.rows);
        tmp_constraint.nz_jac_cols(jac_index) = dep_indices(jac_nz_pattern.cols);
        
        
        if nlp.options.derivative_level == 2 
            % if user-defined Hessian functions are provided
            hes_index = hes_index_offset + ...
                cumsum(ones(1,nlp.constr_array(i).nnz_hess));
            if ~isempty(hes_index)
                hes_index_offset = hes_index(end);
                % set the indices of non-zero Hessian elements
                tmp_constraint.nz_hess_indices{i} = hes_index;
                % get the sparsity pattern (i.e., the indices of non-zero elements)
                % of the Jacobian of the current function
                hess_nz_pattern = nlp.constr_array(i).hess_nz_pattern;
                tmp_constraint.nz_hess_rows(hes_index) = dep_indices(hess_nz_pattern.rows);
                tmp_constraint.nz_hess_cols(hes_index) = dep_indices(hess_nz_pattern.cols);
            end
        end
    end
    
    
    
    tmp_constraint.dimension = sum([nlp.constr_array(:).dimension]);
    tmp_constraint.cl = vertcat(nlp.constr_array(:).lb);
    tmp_constraint.cu = vertcat(nlp.constr_array(:).ub);
    obj.constraint = tmp_constraint;
    
    
    
%     %% If using user-defined Hessian functions
%     
%     if nlp.options.withHessian
%         nnzCostHess = sum([obj.costArray.nnz_hesss]);
%         
%         hessCostNonzeroIndex = ones(nnzCostHess,2);
%         
%         for i=1:nCosts
%             cost = obj.costArray(i);
%             % sparse structure of the Hessian matrix
%             hess_struct = cost.hess_struct;
%             % get indices of non-zero entries of Hessian matrix
%             h_index = cost.h_index;
%             % get indices of dependent variables
%             dep_indices = cost.dep_vars;
%             
%             if ~cost.is_linear
%                 hessCostNonzeroIndex(h_index,1) = dep_indices(hess_struct(:,1));
%                 hessCostNonzeroIndex(h_index,2) = dep_indices(hess_struct(:,2));
%             end
%         end
%         
%         
%         nnzConstrHess = sum([obj.constr_array.nnz_hesss]);
%         hessConstrNonzeroIndex = ones(nnzConstrHess,2);
%         
%         for i=1:nConstr
%             constr = obj.constr_array(i);
%             
%             % sparse structure of the Hessian matrix
%             hess_struct = constr.hess_struct;
%             % get indices of non-zero entries of Hessian matrix
%             h_index = constr.h_index;
%             % get indices of dependent variables
%             dep_indices = constr.dep_vars;
%             
%             if ~constr.is_linear
%                 hessConstrNonzeroIndex(h_index,1) = dep_indices(hess_struct(:,1));
%                 hessConstrNonzeroIndex(h_index,2) = dep_indices(hess_struct(:,2));
%             end
%         end
%         
%         obj.nnz_hesss = nnzCostHess + nnzConstrHess;
%         obj.hessNonzeroIndex = [hessCostNonzeroIndex;hessConstrNonzeroIndex];
%     else
%         obj.nnz_hesss = [];
%         obj.hessNonzeroIndex = [];
%     end
end