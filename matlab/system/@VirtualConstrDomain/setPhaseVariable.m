function obj = setPhaseVariable(obj, type, var)
    % Sets the parameterized time variable (phase variable)
    %
    % Parameters:
    % type: The type of phase variable, it could be either
    % 'TimeBased' or 'StateBased' @type char
    % var: only valid if use 'StateBased' variable.
    % @type Kinematics


    obj.PhaseVariable.Type = type;

    if strcmp(type,'StateBased')
        if getDimension(var) > 1
            error('The phase variable must be a scalar kinematic function');
        end

        obj.PhaseVariable.Var = var;
        % reload the domain-specific naming configurations
        obj.PhaseVariable.Var.Prefix = 'p';
        obj.PhaseVariable.Var.Name = obj.Name;

        % if the phase variable is a KinematicExpr object with
        % parameters, then initialize the scaling parameter set
        if isa(var, 'KinematicExpr')
            if ~isempty(var.Parameters)
                obj.Parameters.p = nan(1,var.Parameters.Dimension);
            else
                obj.Parameters.p = [];
            end
        end
    end

end