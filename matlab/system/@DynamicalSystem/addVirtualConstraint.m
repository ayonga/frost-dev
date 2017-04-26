function obj = addVirtualConstraint(obj, constr)
    % Adds a set of virtual constraints to the dynamical system
    %
    %
    % Parameters:
    % name: the name of the constraint @type char
    % constr: the VirtualConstraint object @type VirtualConstraint
    %
    
    % validate input argument
    validateattributes(constr, {'VirtualConstraint'},...
        {},'DynamicalSystem', 'VirtualConstraints');
    
    n_constr = numel(constr);
    
    for i=1:n_constr
        vc = constr(i);
        c_name = vc.Name;
    
        if isfield(obj.VirtualConstraints, c_name)
            error('The virtual constraint (%s) has been already defined.\n',c_name);
        else
            
            % add virtual constraint
            obj.VirtualConstraints.(c_name) = vc;

            % add output parameters
            obj = addParam(obj, ['a' c_name], vc.OutputParams);
            % add phase parameters
            if ~isempty(vc.PhaseParams)
                obj = addParam(obj, ['p' c_name], vc.PhaseParams);
            end
        end
    
    end
end