function R = rpy2rot(q)
    % rpy_to_rotation(q) computes the rotation matrix from the given (roll,
    % pitch, yaw) angles.
    
    assert(numel(q) == 3, 'The input argument must be a vector of dimension 3.');
    Rz = @(th) [cos(th), -sin(th), 0; sin(th), cos(th), 0; 0,0,1];
    Ry = @(th) [cos(th), 0, sin(th); 0, 1, 0; -sin(th), 0, cos(th)];
    Rx = @(th) [1,0,0; 0, cos(th), -sin(th); 0, sin(th), cos(th)];
    R = Rz(q(3))*Ry(q(2))*Rx(q(1));
    
end