function [obj] = update(obj)
    % Updates the NLP problems before load it to NLP solver
    %
    % @note Overload the superclass (NonlinearProgram) for additional
    % updates
    
    
    % initialize the type of the variables
    obj.VariableArray = NlpVariable.empty();
    obj.CostArray  = NlpFunction.empty();
    obj.ConstrArray = NlpFunction.empty();
    phase = obj.Phase;
    n_phase = length(phase);
    
    index_s = 1;
    % register variables
    for i=1:n_phase
        
        % register variables
        obj = regVariable(obj, phase(i).OptVarTable);
        
        index_f = sum([obj.VariableArray.Dimension]);
        obj.PhaseVarIndices(i,:)= [index_s, index_f];
        index_s = index_f+1;
        
        % register constraints
        obj = regConstraint(obj, phase(i).ConstrTable);
        
        % register cost functions
        obj = regObjective(obj, phase(i).CostTable);
        
        
        
    end
    
    
    
    
    obj = update@NonlinearProgram(obj);
    
end