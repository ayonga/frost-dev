function mass = getTotalMass(obj)
    % Return the total mass of the robot model
    %
    % Return values:
    % mass: the total mass of the robot @type double
    mass = sum([obj.Links.Mass]);
end