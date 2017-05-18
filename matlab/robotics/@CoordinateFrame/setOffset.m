function obj = setOffset(obj, offset)
    % set the offset of the origin of the frame from the reference
    % frame origin (in the reference frame)
    %
    % Parameters:
    % offset: the offset vector @type rowvec
    
    if iscolumn(offset)
        offset = offset';
    end
    
    offset = roundn(offset,-6);
    % validate if it is a numeric 1x3 vector
    validateattributes(offset, {'numeric'},{'size',[1,3]});
    obj.Offset = offset;
    
    % update the homogeneous transformation matrix
    obj.computeHomogeneousTransform();
end