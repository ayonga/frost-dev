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
    
    
    
    
    switch obj.Model.Type
        case 'FirstOrder'
            if obj.DerivativeOrder == 1
                Jh = feval(obj.Jh_name, x);
                dJh = [];
            else
                Jh = feval(obj.Jh_name, x);
                dJh = feval(obj.dJh_name, x);
            end
        case 'SecondOrder'
            Jh = feval(obj.Jh_name, x);
            dJh = feval(obj.dJh_name, x, dx);
    end
    
    
    
    
    
    
end