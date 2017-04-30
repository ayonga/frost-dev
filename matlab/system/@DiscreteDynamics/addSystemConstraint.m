function nlp = addSystemConstraint(obj, nlp, src, tar, bounds)
    % Impose system specific constraints as NLP constraints for the
    % trajectory optimization problem
    %
    % Parameters:
    % nlp: an trajectory optimization NLP object of the system
    % @type TrajectoryOptimization
    % src_nlp: the NLP of the source domain system
    % @type TrajectoryOptimization
    % tar_nlp: the NLP of the target domain system
    % @type TrajectoryOptimization
    % bounds: a struct data contains the boundary values @type struct
    
    
    % by default, identity map
    x_minus = obj.States.xminus;
    x_plus = obj.States.xplus;
    x_map = SymFunction(['xDiscreteMap' obj.Name],x_minus-x_plus,{x_minus,x_plus});
    
    addNodeConstraint(nlp, x_map, {'xminus','xplus'}, 'first', 0, 0, 'Linear');
    
    
    if strcmp(obj.Plant.Type,'SecondOrder')
        dx_minus = obj.States.dxminus;
        dx_plus = obj.States.dxplus;
        dx_map = SymFunction(['dxDiscreteMap' obj.Name],dx_minus-dx_plus,{dx_minus,dx_plus});
        
        addNodeConstraint(nlp, dx_map, {'dxminus','dxplus'}, 'first', 0, 0, 'Linear');
    end
    
    
end
