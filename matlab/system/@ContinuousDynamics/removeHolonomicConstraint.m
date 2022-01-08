function obj = removeHolonomicConstraint(obj, name)
    % Remove holonomic constraints defined for the system
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
    n_constr = numel(name);
    param_names = cell(1,n_constr);
    input_names = cell(1,n_constr);
    
    for i=1:n_constr
        constr = name{i};
        
        if isfield(obj.HolonomicConstraints, constr)
            c_obj = obj.HolonomicConstraints.(constr);
            obj.HolonomicConstraints = rmfield(obj.HolonomicConstraints,constr);
            param_names{i} = c_obj.p_name;
            input_names{i} = c_obj.f_name;
        else
            error('The holonomic constraint (%s) does not exist.\n',constr);
        end
    end
    
    
    obj = removeParam(obj,param_names{:});
    obj = removeInput(obj,input_names{:});
    
end
    