function obj = addEvent(obj, events)
    % Adds event function for the dynamical system 
    %
    % Parameters:   
    %  events: the event function @type EventFunction

    arguments
        obj ContinuousDynamics
    end
    arguments (Repeating)
        events EventFunction
    end
    
    if isempty(events)
        return;
    end
    
    n_events = numel(events);
    
    for i=1:n_events
        event = events{i};
        event_name = event.Name;
    
        if isfield(obj.EventFuncs, event_name)
            warning('The Event condition (%s) has been already defined.\n',event_name);
        else
            obj.EventFuncs.(event_name) = event;
        end
    
    end
end
