function [Jh,dJh] = calcJacobian(obj, x, dx)
    % calculate the holonomic constraints, Jacobian and its time
    % derivatives
    %
    % Parameters:
    % x: the states @type colvec
    % dx: the first order derivatives @type colvec
    %
    % Return values:
    %  Jh: the first-order Jacobian of the constraint @type matrix
    %  dJh: the time derivative of the Jacobian matrix @type matrix
    
    
    
    
    switch obj.SystemType
        case 'FirstOrder'
            Jh = feval(obj.Jh_name, x);
            if nargout > 1
                switch obj.RelativeDegree
                    case 1
                        dJh = [];
                    case 2
                        dJh = feval(obj.dJh_name, x);
                end
            end
        case 'SecondOrder'
            Jh = feval(obj.Jh_name, x);
            if nargout > 1
                dJh = feval(obj.dJh_name, x, dx);
            end
    end
    
    
    
    
    
    
end