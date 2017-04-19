function obj = setRotationMatrix(obj,r)
    % set the rotation matrix (R) of the frame w.r.t to the
    % reference frame
    %
    % Parameters:
    % r: the rotation matrix or Euler angles (in radian) @type
    % rowvec|matrix
    
    if isvector(r) && length(r) == 3
        rpy = rad2deg(r);
        obj.R = rotz(rpy(3)) * roty(rpy(2)) * rotx(rpy(1));
    elseif all(size(r)==[3,3])
        assert(abs(det(r))==1,...
            'The determinant of the rotation matrix must equal 1.');
        obj.R = r;
    end
    
    % update the homogeneous transformation matrix
    obj.computeHomogeneousTransform();
end