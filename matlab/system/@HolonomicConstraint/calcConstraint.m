function varargout = calcConstraint(obj, x, dx)
    % calculate the holonomic constraints, Jacobian and its time
    % derivatives
    %
    % Parameters:
    % x: the states @type colvec
    % dx: the first order derivatives @type colvec
    %
    % Return values:
    % varargout: variable outputs in the following order:
    %  Jac: the first-order Jacobian of the constraint @type matrix
    %  dJac: the time derivative of the Jacobian matrix @type matrix
    %  h: the actual value of the holonomic constraint @type colvec
    
    model_type = obj.Model.Type;
    
    hd = zeros(obj.Dimension,1);
    
    switch model_type
        case 'FirstOrder'
            order = obj.DerivativeOrder;
            if order == 1
                varargout{1} = feval(obj.Jh_.Name, x);
                varargout{2} = feval(obj.h_.Name, x, hd);
            else
                varargout{1} = feval(obj.Jh_.Name, x);
                varargout{2} = feval(obj.dJh_.Name, x);
                varargout{3} = feval(obj.h_.Name, x, hd);
            end
        case 'SecondOrder'
            varargout{1} = feval(obj.Jh_.Name, x);
            varargout{2} = feval(obj.dJh_.Name, x, dx);
            varargout{3} = feval(obj.h_.Name, x, hd);
    end
    
    
    
    
    
    
end