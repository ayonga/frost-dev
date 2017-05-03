function obj = configureOptVariables(obj)
    % This function configures the structure of the optimization variable
    % by adding (registering) them to the optimization variable table.
    %
    % A particular project might inherit the class and overload this
    % function to achieve custom configuration of the optimization
    % variables
    
    n_phase = length(obj.Phase);
    
    
    for i=1:n_phase
        % time variable
        obj = addTimeVariable(obj, i, 0.3);
        
        % state variables
        obj = addStateVariable(obj, i);
        
        % control variables
        obj = addControlVariable(obj, i);
        
        if obj.Options.EnableVirtualConstraint
            % parameter variables
            obj = addParamVariable(obj, i);
        end
        
%         if ~obj.Phase{i}.IsTerminal
%             % guard variables
%             obj = addGuardVariable(obj, i);
%         end
    end
    
end