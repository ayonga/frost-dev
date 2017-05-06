function h = calcConstraint(obj, x)
    % calculate the holonomic constraints
    %
    % Parameters:
    % x: the states @type colvec
    % dx: the first order derivatives @type colvec
    %
    % Return values:
    %  h: the value of the holonomic constraint
    
    hd = zeros(obj.Dimension,1);
    h = feval(obj.h_name, x, hd);
    
end