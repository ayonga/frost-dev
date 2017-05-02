function obj = setReference(obj, ref)
    % set the reference frame
    %
    % Parameters:
    % ref: the reference frame object @type CoordinateFrame
    
    assert(isa(ref,'CoordinateFrame'),...
        'The reference frame must be a CoordinateFrame object.');
    obj.Reference = ref;
    
    % update the homogeneous transformation matrix
    obj.computeHomogeneousTransform();
end