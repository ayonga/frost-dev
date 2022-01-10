function obj = removeVirtualConstraint(obj, name)
    % Remove virtual constraints defined for the system
    %
    % Parameters:
    % name: the name of the constraint @type cellstr
    
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
        constr = name{i};
        
        if isfield(obj.VirtualConstraints, constr)
            c_obj = obj.VirtualConstraints.(constr);
            obj = removeParam(obj,c_obj.OutputParamName);
            if ~isempty(c_obj.PhaseParams)
                obj = removeParam(obj,c_obj.PhaseParamName);
            end
            obj.VirtualConstraints = rmfield(obj.VirtualConstraints,constr);
        else
            error('The virtual constraint (%s) does not exist.\n',constr);
        end
    end
end
    