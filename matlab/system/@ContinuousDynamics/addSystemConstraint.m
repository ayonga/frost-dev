function nlp = addSystemConstraint(obj, nlp)
    % Impose system specific constraints as NLP constraints for the
    % trajectory optimization problem
    %
    % Parameters:
    % nlp: an trajectory optimization NLP object 
    % @type TrajectoryOptimization

    
       
    
    % the holonomic constraints are enforced at the first node, the
    % derivatives of the holonomic constraints are enforced at all nodes
    h_constr_names = fieldnames(obj.HolonomicConstraints);
    n_h_constr = length(h_constr_names);
    if n_h_constr > 0
        
        
        for i=1:n_h_constr
            constr_name = h_constr_names{i};
            constr = obj.HolonomicConstraints.(constr_name);
            
            nlp = constr.imposeNLPConstraint(nlp);
        end
    end
    
    
    % the unilateral constraints are enforced at all nodes
    u_constr_names = fieldnames(obj.UnilateralConstraints);
    n_u_constr = length(u_constr_names);
    if n_u_constr > 0
        
        
        for i=1:n_u_constr
            constr_name = u_constr_names{i};
            constr = obj.UnilateralConstraints.(constr_name);
            nlp = constr.imposeNLPConstraint(nlp);
        end
    end
    
    
    
end
