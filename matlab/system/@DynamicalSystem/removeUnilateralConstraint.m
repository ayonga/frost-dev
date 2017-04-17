function obj = removeUnilateralConstraint(obj, name)
    % Remove unilateral constraints defined for the system
    %
    % Parameters:
    % name: the name of the constraint @type cellstr
    
    assert(ischar(name) || iscellstr(name), ...
        'The name must be a character vector or cellstr.');
    if ischar(name), name = cellstr(name); end
    
    
    for i=1:length(name)
        constr = name{i};
        
        if isfield(obj.UnilateralConstraints, constr)
            obj.UnilateralConstraints = rmfield(obj.UnilateralConstraints,constr);
        else
            error('The unilateral constraint (%s) does not exist.\n',constr);
        end
    end
end
    