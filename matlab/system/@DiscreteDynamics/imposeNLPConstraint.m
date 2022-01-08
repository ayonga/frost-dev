function nlp = imposeNLPConstraint(obj, nlp, varargin)
    % Impose system specific constraints as NLP constraints for the
    % trajectory optimization problem
    %
    % Parameters:
    % nlp: an trajectory optimization NLP object of the system
    % @type TrajectoryOptimization
    
    % by default, identity map
    arguments
        obj DiscreteDynamics
        nlp TrajectoryOptimization        
    end
    arguments (Repeating)
        varargin
    end
    
    x_pre = obj.States.x;
    x_post = obj.States.xn;
    
    x_map = SymFunction(['xDiscreteMap_' obj.Name],x_pre-x_post,{x_pre,x_post});
    
    addNodeConstraint(nlp, 'first', x_map, {x_pre.Name,x_post.Name}, 0, 0);
    
    if strcmp(obj.Type,'SecondOrder')
        dx_pre = obj.States.dx;
        dx_post = obj.States.dxn;
    
        dx_map = SymFunction(['dxDiscreteMap_' obj.Name],dx_pre-dx_post,{dx_pre,dx_post});
    
        addNodeConstraint(nlp, 'first', dx_map, {dx_pre.Name,dx_post.Name}, 0, 0);
    end
end
