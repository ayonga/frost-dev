function [J] = getBodyJacobian(obj, frame, p)
    % Returns the symbolic representation of the body jacobians of
    % coordinate frames
    %
    % Each coordiante
    % 
    %
    % Parameters:
    % frame: the list of coordinate frame of the point 
    % @type cell
    % p: the offset of the point from the origin of the frame 
    % @type matrix
    % 
    % Return values:
    % J: the 6xnDof Jacobian matrix of a rigid coordinate frame @type SymExpression
    %
    %
    % @note Syntax for ont point
    %  
    % >> jac = getBodyJacobian(obj,{'Link1',[0,0,0.1]})
    %
    % @note Syntax for multiple points
    % 
    % >> [jac1,jac2] = getBodyJacobian(obj,{'Link1',[0,0,0.1]},{'Link2',[0.2,0,0.1]})
    
    
    if nargin < 3
        p = [];
    end
    c_str = getTwists(frame, p);
    
    jac = eval_math_fun('ComputeBodyJacobians',[c_str, {obj.numState}]);
    
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