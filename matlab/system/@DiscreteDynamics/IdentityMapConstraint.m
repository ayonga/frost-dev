function nlp = IdentityMapConstraint(obj, nlp, src, tar, bounds, varargin)
    % Impose system specific constraints as NLP constraints for the
    % trajectory optimization problem
    %
    % Parameters:
    % nlp: an trajectory optimization NLP object of the system
    % @type TrajectoryOptimization
    % src: the NLP of the source domain system
    % @type TrajectoryOptimization
    % tar: the NLP of the target domain system
    % @type TrajectoryOptimization
    % bounds: a struct data contains the boundary values @type struct
    % varargin: extra arguments @type varargin
    
    % by default, identity map
    x = obj.States.x;
    xn = obj.States.xn;
    x_map = SymFunction(['xDiscreteMap' obj.Name],x-xn,{x,xn});
    
    addNodeConstraint(nlp, x_map, {'x','xn'}, 'first', 0, 0, 'Linear');
    
    
    if strcmp(obj.Plant.Type,'SecondOrder')
        dx = obj.States.dx;
        dxn = obj.States.dxn;
        dx_map = SymFunction(['dxDiscreteMap' obj.Name],dx-dxn,{dx,dxn});
        
        addNodeConstraint(nlp, dx_map, {'dx','dxn'}, 'first', 0, 0, 'Linear');
    end
    
    
end
