function obj = removeEvent(obj, name)
    % Remove event functions defined for the system
    %
    % Parameters:
    % name: the name of the event @type cellstr
    
    arguments
        obj ContinuousDynamics
    end
    arguments (Repeating)
        name char
    end
    
    if isempty(name)
        return
    end
    
    
    for i=1:length(name)
        event_name = name{i};
        
        if isfield(obj.EventFuncs, event_name)
            %             event = obj.EventFuncs.(event_name);
            obj.EventFuncs = rmfield(obj.EventFuncs,event_name);            
            %             delete(event);
        else
            error('The event (%s) does not exist.\n',event_name);
        end
    end
end
    