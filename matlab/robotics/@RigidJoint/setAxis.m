function obj = setAxis(obj, axis)
    % set the joint rotation axis vector in the joint coordinate
    %
    % Parameters:
    % axis: the axis vector @type rowvec
    
    
    
    
    if any(isnan(axis))
        return;
    end
    
    
    if iscolumn(axis)
        axis = axis';
    end
    
    % validate if it is a numeric 1x3 vector
    validateattributes(axis, {'numeric'},{'size',[1,3]});
    
    if ~all(axis == [0,0,0])
        tol = 1e-1;
        assert(abs(norm(axis) - 1) < tol,...
            'The axis must be a unit vector.');
    end
    obj.Axis = axis;
    obj.updateTwistAxis();
end