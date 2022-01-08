function obj = addState(obj, states)
    % addState(obj, states) adds state variables to the dynamical
    % system
    %
    % Parameters:
    %  states (repeatable): the state variables
    
    arguments
        obj DynamicalSystem        
    end
    
    arguments (Repeating)
        states StateVariable
    end
    
    for i=1:length(states)
        name = states{i}.Name;
        
        if isfield(obj.States, name)
            warning('The states (%s) has been already defined.\n',name);
        else
            obj.States.(name) = states{i};
            obj.states_.(name) = nan(size(states{i}));
        end
    end
    
    
end
