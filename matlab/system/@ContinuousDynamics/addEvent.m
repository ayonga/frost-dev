function obj = addEvent(obj, constr)
    % Adds event function for the dynamical system states and inputs
    %
    % Parameters:   
    %  constr: the event function @type UnilateralConstraint

    % validate input argument
    validateattributes(constr, {'UnilateralConstraint'},...
        {},'ContinuousDynamics', 'EventFuncs');
    
    n_constr = numel(constr);
    
    for i=1:n_constr
        c_obj = constr(i);
        c_name = c_obj.Name;
    
        if isfield(obj.EventFuncs, c_name)
            error('The unilateral constraint (%s) has been already defined.\n',c_name);
        else
            assert(c_obj.Dimension==1,'Each event function must be a scalar unilateral constraint function.');
            % add event function
            obj.EventFuncs.(c_name) = c_obj;
            
        end
    
    end
end
