function obj = setInertia(obj, inertia)
    % sets the inertia (matrix) of the link
    %
    % Parameters:
    % inertia: the inertia matrix @type matrix
    arguments
        obj
        inertia (3,3) double {mustBeReal, mustBeNonNan} = zeros(3)
    end
    
    obj.Inertia = inertia;
end