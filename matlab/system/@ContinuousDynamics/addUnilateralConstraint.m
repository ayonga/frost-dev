function obj = addUnilateralConstraint(obj, constr)
    % Adds unilateral (inequality) constraints on the dynamical system
    % states and inputs
    %
    % Parameters:   
    %  name: the name of the constraint @type char
    %  constr: the unilateral constraints @type UnilateralConstraint

    % validate input argument
    validateattributes(constr, {'UnilateralConstraint'},...
        {},'ContinuousDynamics', 'UnilateralConstraint');
    
    n_constr = numel(constr);
    
    for i=1:n_constr
        c_obj = constr(i);
        c_name = c_obj.Name;
    
        if isfield(obj.UnilateralConstraints, c_name)
            error('The unilateral constraint (%s) has been already defined.\n',c_name);
        else
            
            % add virtual constraint
            obj.UnilateralConstraints.(c_name) = c_obj;

            
        end
    
    end
end
