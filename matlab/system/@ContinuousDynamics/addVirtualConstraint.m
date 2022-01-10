function obj = addVirtualConstraint(obj, constr)
    % Adds a set of virtual constraints to the dynamical system
    %
    %
    % Parameters:
    % constr: the VirtualConstraint object @type VirtualConstraint
    %
    
    % validate input argument
    arguments
        obj ContinuousDynamics
    end
    arguments (Repeating)
        constr VirtualConstraint
    end
    
    n_constr = numel(constr);
    
    for i=1:n_constr
        c_obj = constr{i};
        c_name = c_obj.Name;
    
        if isfield(obj.VirtualConstraints, c_name)
            error('The virtual constraint (%s) has been already defined.\n',c_name);
        else
            
            % add virtual constraint
            obj.VirtualConstraints.(c_name) = c_obj;

            % add output parameters
            obj = addParam(obj, c_obj.OutputParams);
            % add phase parameters
            if ~isempty(c_obj.PhaseParams)
                obj = addParam(obj,  c_obj.PhaseParams);
            end
            
        end
    
    end
end