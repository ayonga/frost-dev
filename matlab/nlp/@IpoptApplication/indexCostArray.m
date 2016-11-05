function costArray = indexCostArray(obj)
    % This function converts the cell array of registered cost functions of
    % the NLP into a NlpCost object array, then updates the index for all
    % registered cost function array. 
    %
    % The original cost function array of an NLP could be 1-D or 2-D cell
    % array. Here we convert such data structure into 1-D object array, so
    % that indexing these functions becomes much easier.
    %
    % Return values:
    %  costArray: an NlpCost object array of cost functions with updated
    %  indexing information @type NlpCost
    
    
    nlp = obj.nlp;
    % convert the cell array into object array
    costArray = vertcat(nlp.costArray{:});
    
    % 
    nCosts = numel(costArray);
    
    % initialize index to be zero
    jIndex0 = 0;
    hIndex0 = 0;
    
    for i=1:nCosts
        cost = costArray(i);
        cost = setJacIndices(cost, jIndex0);
        
        % update offset
        jIndex0 = jIndex0 + cost.nnzJac;
        
        if nlp.options.withHessian
            cost = setHessIndices(cost, hIndex0);
            
            % update offset
            hIndex0 = hIndex0 + cost.nnzHess;
        end
        costArray(i) = cost;
        
    end
    
    
    
end