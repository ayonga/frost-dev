function obj = genCostIndices(obj)
    % This function generates the indexing information for cost
    % functions
    
    nCosts = numel(obj.costArray);
    
    jIndex0 = 0;
    hIndex0 = 0;
    
    for i=1:nCosts
        cost = obj.costArray(i);
        cost = setJacIndices(cost, jIndex0);
        
        % update offset
        if ~isempty(cost.j_index)
            jIndex0 = cost.j_index(end);
        end
        
        if obj.options.withHessian
            cost = setHessIndices(cost, hIndex0);
            if ~isempty(cost.h_index)
                hIndex0 = cost.h_index(end);
            end
        end
        obj.costArray(i) = cost;
        
    end
    
end