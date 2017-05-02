function [obj] = update(obj)
    % Updates the NLP problems before load it to NLP solver
    %
    % @note Overload the superclass (NonlinearProgram) for additional
    % updates
    
    
    % initialize the type of the variables
    obj.VariableArray = NlpVariable.empty();
    obj.CostArray  = NlpFunction.empty();
    obj.ConstrArray = NlpFunction.empty();

    
        
    % register variables
    obj = regVariable(obj, obj.OptVarTable);
    
    % register constraints
    obj = regConstraint(obj, obj.ConstrTable);
    
    % register cost functions
    obj = regObjective(obj, obj.CostTable);
    
    
    
    obj = update@NonlinearProgram(obj);
    
    
    
end