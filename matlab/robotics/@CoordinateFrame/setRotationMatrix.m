function obj = setRotationMatrix(obj,r)
    % set the rotation matrix (R) of the frame w.r.t to the
    % reference frame
    %
    % Parameters:
    % r: the rotation matrix or Euler angles (in radian) @type
    % rowvec|matrix
    
    if isempty(r)
        return;
    end
    
    if isvector(r) && length(r) == 3
        %         rpy = rad2deg(r);
        obj.R = rpy2rot(r); %rotz(r(3)) * roty(r(2)) * rotx(r(1));
    elseif all(size(r)==[3,3])
        if isnumeric(r)
            assert(abs(det(r))-1 <= 1e-6,...
                'The determinant of the rotation matrix must equal 1.');
        end
        obj.R = r;
    else
        error('The parameter `R` must be either a 3x3 rotation matrix or 3x1 roll-pitch-yaw vector.');
    end
    % remove small numbers generated from the rotation matrix
    if isnumeric(r)
        obj.R = roundn(obj.R,-6);
    end
    % update the homogeneous transformation matrix
    obj.updateTransform();
end
