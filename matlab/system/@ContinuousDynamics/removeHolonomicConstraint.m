function obj = removeHolonomicConstraint(obj, name)
    % Remove holonomic constraints defined for the system
    %
    % Parameters:
    % name: the name of the constraint @type cellstr
    
    assert(ischar(name) || iscellstr(name), ...
        'The name must be a character vector or cellstr.');
    if ischar(name), name = cellstr(name); end
    
    
    for i=1:length(name)
        constr = name{i};
        
        if isfield(obj.HolonomicConstraints, constr)
            c_obj = obj.HolonomicConstraints.(constr);
            obj.HolonomicConstraints = rmfield(obj.HolonomicConstraints,constr);
            obj = removeParam(obj,c_obj.ParamName);
            obj = removeInput(obj,'ConstraintWrench',c_obj.InputName);
        else
            error('The holonomic constraint (%s) does not exist.\n',constr);
        end
    end
end
    