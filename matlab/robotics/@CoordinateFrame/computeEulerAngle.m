function rpy = computeEulerAngle(obj)
    % computes the Euler angles the body (current) coordinate frame
    % in the world frame (base coordinate)
    %
    % Return values:
    % rpy: the Euler (roll,pitch,yaw) angles of the frame
    % @type SymExpression
    
    % compute the transformation matrix of the origin
    gst = obj.computeForwardKinematics();
    
    % compute rigid orientation
    Rot = CoordinateFrame.RigidOrientation(gst);
    % compute rigid orientation with initial tool configuration (q = 0)
    Rot0 = CoordinateFrame.RigidOrientation(obj.gst0);
    % compute spatial orientation
    RotW = Rot * transpose(Rot0);
    % compute Euler angles
    yaw = atan2(RotW(2,1),RotW(1,1));
    roll = atan2(RotW(3,2),RotW(3,3));
    pitch = atan2(-RotW(3,1) * cos(roll),RotW(3,3));
    
    rpy = [roll; pitch; yaw];
end