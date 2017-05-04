function ang= getEulerAngles(obj, frame, p)
    % Returns the symbolic representation of the Euler angles of a
    % rigid link.
    %
    % Parameters:
    % frame: the list of coordinate frame of the point 
    % @type cell
    % p: the offset of the point from the origin of the frame 
    % @type matrix
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
    if nargin < 3
        p = [];
    end
    c_str = getTwists(frame, p);
        
    ang = eval_math_fun('ComputeEulerAngles',c_str);
    
   
    
end