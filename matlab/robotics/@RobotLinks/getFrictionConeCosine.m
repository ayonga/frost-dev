function ang= getFrictionConeCosine(obj, frame, a, R, p)
    % Returns the symbolic representation of the Euler angles of a
    % rigid link.
    %
    % Parameters:
    % frame: the list of coordinate frame of the point 
    % @type cell
    % R: ang is computed as the relative Euler angles from frame to R
    % @type matrix
    % p: the offset of the point from the origin of the frame 
    % @type matrix
    %
    % 
    % Return values:    
    %  ang: the 3-dimensional Euler angles (roll,pitch,yaw) vector of the
    %  CoM of the system @type SymExpression
    %
    %
    % @note Syntax for ont point
    %  
    % >> getEulerAngles(obj,pf,offset)
    %
    % @note Syntax for multiple points (offset should be np*3 matrix)
    % 
    % >> getEulerAngles(obj,pfarray, offset)
    
    
    % the number of points (one less than the nargin)

    if nargin < 5
        p = [];
    end
    if nargin < 4
        R = eye(3);
    end
    if nargin < 3
        a = [0,0,0];
    end
    c_str = getTwists(frame, p);
    c_str{1}.R = R;
    c_str{1}.a = a;
        
    ang = eval_math_fun('ComputeFrictionConeCosine', c_str);
    
   
    
end