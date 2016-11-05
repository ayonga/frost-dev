function constrArray = indexConstraintArray(obj)
    % This function converts the cell array of registered constraints of
    % the NLP into a NlpConstraint object array, then updates the index for
    % all registered constraints array.
    %
    % The original constraints array of an NLP could be 1-D or 2-D cell
    % array. Here we convert such data structure into 1-D object array, so
    % that indexing these functions becomes much easier.
    %
    % Return values:
    %  constrArray: an NlpConstraint object array of cost functions with
    %  updated indexing information @type NlpConstraint
    
    
    nlp = obj.nlp;
    
    % convert the cell array into object array
    constrArray = vertcat(nlp.constrArray{:});
    
    nConstrs = numel(constrArray);
    
    cIndex0 = 0;
    jIndex0 = 0;
    hIndex0 = 0;
    
    for i=1:nConstrs
        constr = constrArray(i);
        % set the indices for constraints and non-zero Jacobian
        % entries
        constr = setConstrIndices(constr, cIndex0);
        constr = setJacIndices(constr, jIndex0);
        
        % update the initial offset
        cIndex0 = cIndex0 + constr.dims;
        jIndex0 = jIndex0 + constr.nnzJac;
        
        % if Hessian functions are provided, updated indices
        if nlp.options.withHessian
            constr = setHessIndices(constr, hIndex0);
            % update the initial offset
            hIndex0 = hIndex0 + constr.nnzHess;
        end
        constrArray(i) = constr;
        
    end
end