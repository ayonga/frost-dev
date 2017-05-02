function obj = computeHomogeneousTransform(obj)
    % computes the homogeneous transformation matrix from the world
    % coordinates
    
    if isempty(obj.Reference)
        gst_0 = eye(4);
    else
        gst_0 = obj.Reference.gst0;
    end
    
    if isempty(gst_0) || isempty(obj.R) || isempty(obj.Offset)
        return;
    end
    obj.gst0 = gst_0*CoordinateFrame.RPToHomogeneous(obj.R, obj.Offset);
    
end