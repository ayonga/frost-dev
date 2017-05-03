function obj = setMass(obj, mass)
    % sets the link mass
    %
    % Parameters:
    % mass: the link mass @type double
    
    assert(isreal(mass) && mass >= 0,...
        'The mass of the link must be a positive real scalar value.');
    obj.Mass = mass;
end