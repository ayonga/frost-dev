function obj = removeVirtualConstraint(obj, name)
    % Remove virtual constraints defined for the system
    %
    % Parameters:
    % name: the name of the constraint @type cellstr
    
    assert(ischar(name) || iscellstr(name), ...
        'The name must be a character vector or cellstr.');
    if ischar(name), name = cellstr(name); end
    
    
    for i=1:length(name)
        constr = name{i};
        
        if isfield(obj.VirtualConstraints, constr)
            
            obj = removeParam(obj,['a' constr]);
            if ~isempty(obj.VirtualConstraints.(constr).PhaseParams)
                obj = removeParam(obj,['p' constr]);
            end
            obj.VirtualConstraints = rmfield(obj.VirtualConstraints,constr);
        else
            error('The virtual constraint (%s) does not exist.\n',constr);
        end
    end
end
    