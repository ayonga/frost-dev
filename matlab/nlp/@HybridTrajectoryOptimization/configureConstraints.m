function obj = configureConstraints(obj)
    % This function configures the structure of the optimization variable
    % by adding (registering) them to the optimization variable table.
    %
    % A particular project might inherit the class and overload this
    % function to achieve custom configuration of the optimization
    % variables
    
    n_phase = length(obj.Phase);
    
    
    for i=1:n_phase
        
        obj = addDynamicsConstraint(obj, i);
        
        
        obj = addDomainConstraint(obj, i);
            
        obj = addCollocationConstraint(obj, i);
        
        obj = addJumpConstraint(obj, i);

        obj = addOutputConstraint(obj, i);
        
        obj = addParamConstraint(obj, i);
    end
    
end