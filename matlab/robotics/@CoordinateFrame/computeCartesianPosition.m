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
    
    if nargin > 1
        if iscolumn(p)
            p = p';
        end
        % validate if it is a numeric 1x3 vector
        validateattributes(p, {'numeric'},{'size',[1,3]});
    else
        p = [];
    end
    
    % compute the transformation matrix of the origin
    gst = obj.computeForwardKinematics();
    
    if ~isempty(p) % if p is given
        % compute the relative transformation from the current
        % frame origin
        g0 = CoordinateFrame.RPToHomogeneous(eye(3),p);
        % multiply to the transformation matrix to the frame origin
        g = gst * g0;
    else
        g = gst;
    end
    
    pos = CoordinateFrame.RigidPosition(g);
end