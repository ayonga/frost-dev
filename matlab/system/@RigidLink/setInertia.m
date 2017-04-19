function obj = setInertia(obj, inertia)
    % sets the inertia (matrix) of the link
    %
    % Parameters:
    % inertia: the inertia matrix @type matrix
    
    assert(isreal(inertia) && all(size(inertia)==[3,3]),...
        'The inertia of the link must be a 3x3 positive real matrix.');
    obj.Inertia = inertia;
end