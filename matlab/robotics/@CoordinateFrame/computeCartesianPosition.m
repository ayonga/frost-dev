function pos = computeCartesianPosition(obj, p)
    % computes the cartesian position of a point p in the body
    % (current) coordinate frame
    %
    % @note If (p) is not given, then returns the cartesian
    % positions of the origin of the current coordinate frame.
    %
    % Parameters:
    % p: the offset vector of the point in the current frame
    % @type rowvec
    %
    % Return values:
    % pos: the symbolic expression of the cartesian position
    % @type SymExpression
    
    arguments
        obj
        p (3,1) double = zeros(3,1)
    end
    
    % compute the transformation matrix of the origin
    gst = obj.computeForwardKinematics();
    g0 = CoordinateFrame.RPToHomogeneous(eye(3),p);
    g = gst * g0;
    
    pos = CoordinateFrame.RigidPosition(g);
end