function obj = setAxis(obj, axis)
    % set the joint rotation axis vector in the joint coordinate
    %
    % Parameters:
    % axis: the axis vector @type rowvec
    
    if iscolumn(axis)
        axis = axis';
    end
    % validate if it is a numeric 1x3 vector
    validateattributes(axis, {'numeric'},{'size',[1,3]});
    
    assert(norm(axis)==1,...
        'The axis must be a unit vector.');
    obj.Axis = axis;
    
end