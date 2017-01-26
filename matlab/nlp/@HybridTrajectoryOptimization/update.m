function [obj] = update(obj)
    % Updates the NLP problems before load it to NLP solver
    %
    % @note Overload the superclass (NonlinearProgram) for additional
    % updates
    
    
    % initialize the type of the variables
    obj.VariableArray = cell(0);
    obj.CostArray  = cell(0);
    obj.ConstrArray = cell(0);

    n_phase = length(obj.Phase);
    % register variables
    for i=1:n_phase
        
        % register variables
        obj = regVariable(obj, obj.Phase{i}.OptVarTable);
        
        % register constraints
        obj = regConstraint(obj, obj.Phase{i}.ConstrTable);
        
        % register cost functions
        obj = regObjective(obj, obj.Phase{i}.CostTable);
    end
    
    
    
    
    % update variable indices
    index_offset = 0;
    
    num_vars = numel(obj.VariableArray);

    for i = 1:num_vars
        dim = obj.VariableArray{i}.Dimension;
        
        % set the index
        obj.VariableArray{i} = setIndices(obj.VariableArray{i},...
            index_offset + cumsum(ones(dim, 1)));

        % increments (updates) offset
        index_offset = index_offset + dim;
    end
    
end