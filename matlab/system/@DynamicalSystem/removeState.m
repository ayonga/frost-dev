function obj = removeState(obj, state_names)
    % removeState(model, states) removes state variables from the dynamical
    % system.
    %
    % Parameters:
    %  state_names (repeatable): the name of state variables to be removed
    
    arguments
        obj DynamicalSystem        
    end
    
    arguments (Repeating)
        state_names char
    end
    
    for i=1:length(state_names)
        name = state_names{i};
        
        if isfield(obj.States, name)
            if strcmp('q',name) || strcmp('dq',name)
                error('The state variable (%s) CANNOT be removed. \n',name);              
            end
            
            obj.States.(name) = rmfield(obj.States,name);   
            obj.states_.(name) = rmfield(obj.states_,name);
        else            
            warning('The state variable (%s) does not exist.\n',name);
        end
    end
    
    
end
