function nlp = addSystemConstraint(obj, nlp, bounds)
    % Impose system specific constraints as NLP constraints for the
    % trajectory optimization problem
    %
    % Parameters:
    % nlp: an trajectory optimization NLP object 
    % @type TrajectoryOptimization
    % bounds: a struct data contains the boundary values @type struct
    
    
    %     % virtual constraints
    %     v_constr_names = fieldnames(obj.VirtualConstraints);
    %     n_v_constr = length(v_constr_names);
    %     if n_v_constr > 0
    %
    %
    %         for i=1:n_v_constr
    %             constr_name = v_constr_names{i};
    %             constr = obj.VirtualConstraints.(constr_name);
    %             nlp = constr.imposeNLPConstraint(nlp,k,sel);
    %         end
    %     end
    
end
