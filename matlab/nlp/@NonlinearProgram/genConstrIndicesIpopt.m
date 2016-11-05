function obj = genConstrIndicesIpopt(obj)
    % This function generates the indexing information for
    % constraints for IPOPT
    
    
    nConstrs = numel(obj.constrArray);
    
    cIndex0 = 0;
    jIndex0 = 0;
    hIndex0 = 0;
    
    for i=1:nConstrs
        constr = obj.constrArray(i);
        % set the indices for constraints and non-zero Jacobian
        % entries
        constr = setConstrIndices(constr, cIndex0);
        constr = setJacIndices(constr, jIndex0);
        
        % update the initial offset
        if ~isempty(constr.c_index)
            cIndex0 = constr.c_index(end);
        end
        
        if ~isempty(constr.j_index)
            jIndex0 = constr.j_index(end);
        end
        
        % if Hessian functions are provided, updated indices
        if obj.options.withHessian
            constr = setHessIndices(constr, hIndex0);
            if ~isempty(constr.h_index)
                hIndex0 = constr.h_index(end);
            end
        end
        obj.constrArray(i) = constr;
        
    end
end