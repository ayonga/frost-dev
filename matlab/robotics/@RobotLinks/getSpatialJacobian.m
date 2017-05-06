function [J] = getSpatialJacobian(obj, frame, p)
    % Returns the symbolic representation of the spatial jacobian of the point
    % that is rigidly attached to the link with a given offset.
    %
    % Parameters:
    % frame: the list of coordinate frame of the point 
    % @type cell
    % p: the offset of the point from the origin of the frame 
    % @type matrix
    % 
    % Return values:
    % J: the 6xnDof Jacobian matrix of a rigid point @type SymExpression
    %
    %
    % @note Syntax for ont point
    %  
    % >> getSpatialJacobian(obj,pf,offset)
    %
    % @note Syntax for multiple points (offset should be np*3 matrix)
    % 
    % >> getSpatialJacobian(obj,pfarray, offset)
    
    
    if nargin < 3
        p = [];
    end
    c_str = getTwists(frame, p);
    jac = eval_math_fun('ComputeSpatialJacobians',[c_str, {obj.numState}]);
        
    n_pos = length(frame);
    if n_pos > 1
        J = cell(1,n_pos);
        for i=1:n_pos
            J{i} = jac(i,:);
        end
    else
        J = jac(1,:);
    end
end