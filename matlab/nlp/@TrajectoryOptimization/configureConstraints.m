function obj = configureConstraints(obj, bounds)

    plant = obj.Plant;
    %| @note If the number of node equals 1, then the system is
    %either discrete event system or a ternimal node of a hybrid
    %system. For this type of system, the problem is actually not a
    %trajectory optimization problem. Hence no need to enforce the
    %collocation constraint and dynamics constraint.
    if obj.NumNode > 1
        % impose the collocation constraints
        obj = obj.addCollocationConstraint();
    end   
    % impose the system dynamics equation constraints
    %         obj = obj.addDynamicsConstraint();
    plant.imposeNLPConstraint(obj);
    
    
    % the holonomic constraints are enforced at the first node, the
    % derivatives of the holonomic constraints are enforced at all nodes
    if isprop(plant,'HolonomicConstraints')
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
    end
    
    
    % the unilateral constraints are enforced at all nodes
    if isprop(plant,'UnilateralConstraints')
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
    %     u_constr = plant.EventFuncs;
    %     u_constr_names = fieldnames(u_constr);
    %     n_u_constr = length(u_constr_names);
    %     if n_u_constr > 0
    %         for i=1:n_u_constr
    %             constr_name = u_constr_names{i};
    %             constr = u_constr.(constr_name);
    %             obj = imposeNLPConstraint(constr, obj);
    %         end
    %     end
    
    %     if isprop(plant,'VirtualConstraints')
    %         h_constr = plant.VirtualConstraints;
    %         h_constr_names = fieldnames(h_constr);
    %         n_h_constr = length(h_constr_names);
    %         if n_h_constr > 0
    %             for i=1:n_h_constr
    %                 constr_name = h_constr_names{i};
    %                 constr = h_constr.(constr_name);
    %
    %                 obj = imposeNLPConstraint(constr,obj);
    %             end
    %         end
    %     end
    
    inputs = plant.Inputs;
    input_names = fieldnames(inputs);
    n_input = length(input_names);
    if n_input > 0
        for i=1:n_input
            input_name = input_names{i};
            input = inputs.(input_name);
            if ~isempty(input.CustomNLPConstraint)
                input.CustomNLPConstraint(input, obj, bounds);
            end
        end
    end
    % impose the system specific constraints (such as holonomic
    % constraints and unilateral constraints)
    if ~isempty(plant.CustomNLPConstraint)
        plant.CustomNLPConstraint(obj, bounds);
    end
    
    obj.update();
end