function [pos] = getCartesianPosition(obj, frame, p)
    % Returns the symbolic representation of the Cartesian positions of a
    % rigid point specified by a coordinate frame and an offset
    %
    % Parameters:
    % frame: the list of coordinate frame of the point 
    % @type cell
    % p: the offset of the point from the origin of the frame 
    % @type matrix
    % 
    % Return values:
    % pos: the 3-Dimensional SO(3) position vectors of the fixed rigid
    % points @type SymExpression
    %
    %
    % @note Syntax for ont point
    %  
    % >> getCartesianPosition(obj,pf,offset)
    %
    % @note Syntax for multiple points (offset should be np*3 matrix)
    % 
    % >> getCartesianPosition(obj,pfarray, offset)
    
    if nargin < 3
        p = [];
    end
    c_str = getTwists(frame, p);
    
    pos = eval_math_fun('ComputeCartesianPositions',c_str);
        
       
    
end