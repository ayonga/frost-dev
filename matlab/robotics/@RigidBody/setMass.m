function obj = setMass(obj, mass)
    % sets the link mass
    %
    % Parameters:
    % mass: the link mass @type double
    arguments
        obj
        mass (1,1) double {mustBeReal, mustBeNonnegative, mustBeNonNan} = 0
    end
    
    obj.Mass = mass;
end