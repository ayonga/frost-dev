function obj = configure(obj, bounds, varargin)
    % configure the trajectory optimizatino NLP problem
    %
    % This process will add NLP variables based on the information of the
    % dynamical system object, impose dynamical and collocation
    % constraints, then call the system constraints callback function to
    % add any system-specific constraints.
    %
    % Parameters:
    % bounds: a struct data contains the boundary values @type struct
    
    % configure NLP decision variables
    obj = obj.configureVariables(bounds);
    
    plant = obj.Plant;
    
    %| @note If the number of node equals 1, then the system is
    %either discrete event system or a ternimal node of a hybrid
    %system. For this type of system, the problem is actually not a
    %trajectory optimization problem. Hence no need to enforce the
    %collocation constraint and dynamics constraint.
    if obj.NumNode > 1
        % impose the collocation constraints
        obj = obj.addCollocationConstraint();
        
        % impose the system dynamics equation constraints
        obj = obj.addDynamicsConstraint();
        
        % the holonomic constraints are enforced at the first node, the
        % derivatives of the holonomic constraints are enforced at all nodes
        h_constr = plant.HolonomicConstraints;
        h_constr_names = fieldnames(h_constr);
        n_h_constr = length(h_constr_names);
        if n_h_constr > 0
            for i=1:n_h_constr
                constr_name = h_constr_names{i};
                constr = h_constr.(constr_name);
                
                obj = imposeNLPConstraint(constr,obj);
            end
        end
        
        
        % the unilateral constraints are enforced at all nodes
        u_constr = plant.UnilateralConstraints;
        u_constr_names = fieldnames(u_constr);
        n_u_constr = length(u_constr_names);
        if n_u_constr > 0
            for i=1:n_u_constr
                constr_name = u_constr_names{i};
                constr = u_constr.(constr_name);
                obj = imposeNLPConstraint(constr, obj);
            end
        end
    end
    % impose the system specific constraints (such as holonomic
    % constraints and unilateral constraints)
    if ~isempty(plant.UserNlpConstraint)
        plant.UserNlpConstraint(obj, bounds, varargin{:});
    end
end