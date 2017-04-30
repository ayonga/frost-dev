function obj = addHolonomicConstraint(obj, constr)
    % Adds a holonomic constraint to the dynamical system
    %
    %
    % Parameters:
    % constr: the expression of the constraints @type SymExrpression
    %
    % @note Any holonomic constraint introduces a set of constrained
    % wrenchs to the system (Lagrangian multiplier).
    
    % validate input argument
    validateattributes(constr, {'HolonomicConstraint'},...
        {},'ContinuousDynamics', 'HolonomicConstraint');
    
    n_constr = numel(constr);
    
    for i=1:n_constr
        c_obj = constr(i);
        c_name = c_obj.Name;
    
        if isfield(obj.HolonomicConstraints, c_name)
            error('The holonomic constraint (%s) has been already defined.\n',c_name);
        else
            
            % add virtual constraint
            obj.HolonomicConstraints.(c_name) = c_obj;

            % add constant parameters
            obj = addParam(obj, c_obj.ParamName, c_obj.Param);
            Jh = c_obj.ConstrJac;
            obj = addInput(obj, 'ConstraintWrench', c_obj.InputName, c_obj.Input, transpose(Jh));
        end
    
    end
    
    
end