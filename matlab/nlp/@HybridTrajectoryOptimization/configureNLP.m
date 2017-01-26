function obj = configureNLP(obj, options)
    % Initializes the trajectory optimization problem.
    %
    % Parameters:
    % options: configuration options @type struct
    
    n_phase = length(obj.Phase);
    
    
    for i=1:n_phase
        %% variables
        % time variable
        obj = addTimeVariable(obj, i);
        
        % state variables
        obj = addStateVariable(obj, i);
        
        % control variables
        obj = addControlVariable(obj, i);
        
        % parameter variables
        obj = addParamVariable(obj, i);
        
        % guard variables
        obj = addGuardVariable(obj, i);
        
        
    end
    
    for i=1:n_phase
        %% constraints
        obj = addCollocationConstraint(obj, i);
        
        obj = addDomainConstraint(obj, i);
        
        obj = addDynamicsConstraint(obj, i);
        
%         obj = addJumpConstraint(obj, i);

%         obj = addOutputConstraint(obj, i);
        
%         obj = addParamConstraint(obj, i);
        
        %% cost function
        obj = addRunningCost(obj, i, obj.Funcs.Phase{i}.power);
        
    end
    
    
end