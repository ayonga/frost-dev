function obj = computeTwist(obj)
    % computes the twist from the base frame
    %
    
    xi = obj.getTwist();
    
    if isempty(obj.gst0)
        error('Please run ''computeHomogeneousTransform'' method first.');
    else
        adj = CoordinateFrame.RigidAdjoint(obj.gst0);
        obj.Twist = transpose(adj*transpose(xi));
    end
end