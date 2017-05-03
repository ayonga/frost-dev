function obj = removeEvent(obj, name)
    % Remove event functions defined for the system
    %
    % Parameters:
    % name: the name of the constraint @type cellstr
    
    assert(ischar(name) || iscellstr(name), ...
        'The name must be a character vector or cellstr.');
    if ischar(name), name = cellstr(name); end
    
    
    for i=1:length(name)
        constr = name{i};
        
        if isfield(obj.EventFuncs, constr)
            obj.EventFuncs = rmfield(obj.EventFuncs,constr);
        else
            error('The event (%s) does not exist.\n',constr);
        end
    end
end
    