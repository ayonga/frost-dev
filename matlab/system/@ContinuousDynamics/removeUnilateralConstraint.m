function obj = removeUnilateralConstraint(obj, name)
    % Remove unilateral constraints defined for the system
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
    
    
    for i=1:numel(name)
        constr = name{i};
        
        if isfield(obj.UnilateralConstraints, constr)
            obj.UnilateralConstraints = rmfield(obj.UnilateralConstraints,constr);
        else
            error('The unilateral constraint (%s) does not exist.\n',constr);
        end
    end
end
    