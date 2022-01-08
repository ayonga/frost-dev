function obj = addHolonomicConstraint(obj, constr)
    % Adds a holonomic constraint to the dynamical system
    %
    %
    % Parameters:
    % constr (repeatable: the expression of the constraints @type HolonomicConstraint
    % load_path: the path from which the symbolic expressions for the
    % input map can be loaded @type char
    %
    % @note Any holonomic constraint introduces a set of constrained
    % wrenchs to the system (Lagrangian multiplier).
    
    arguments
        obj ContinuousDynamics
    end
    arguments (Repeating)
        constr HolonomicConstraint
    end
    %     arguments
    %         options.LoadPath char {mustBeFolder} = []
    %     end
    
    %     load_path = options.LoadPath;
    
    if isempty(constr)
        return;
    end
    
    n_constr = numel(constr);
    lambda = cell(1,n_constr);
    params = cell(1,n_constr);
    for i=1:n_constr
        c_obj = constr{i};
        c_name = c_obj.Name;
    
        if isfield(obj.HolonomicConstraints, c_name)
            error('The holonomic constraint (%s) has been already defined.\n',c_name);
        else
            
            % add virtual constraint
            obj.HolonomicConstraints.(c_name) = c_obj;

            % add constant parameters
            params{i} = c_obj.Params;
            
            lambda{i} = InputVariable(c_obj.f_name, c_obj.Dimension,[],[],'ConstraintWrench');
            setGmap(lambda{i},transpose(c_obj.ConstrJac),obj);
        end
    
    end
    
    obj = addParam(obj, params{:});
    obj = addInput(obj, lambda{:});
    
end