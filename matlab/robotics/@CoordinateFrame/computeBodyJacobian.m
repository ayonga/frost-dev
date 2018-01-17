function Jac = computeBodyJacobian(obj, nDof)
    % computes the body Jacobian matrix of the
    % coordinate frame
    %
    % Parameters:
    % nDof: the total degrees of freedom of the system
    % @type integer
    %
    % Return values:
    % Jac: the Jacobian matrix @type SymExpression
    
    frame = obj;
    while ~isprop(frame, 'TwistPairs') %isempty(frame.TwistPairs)
        frame = frame.Reference;
        if isempty(frame)
            error('The coordinate system is not fully defined.');
        end
    end
    
    twists = frame.TwistPairs;
    indices = frame.ChainIndices;
    
    Jz = eval_math_fun('BodyJacobian',[twists,{obj.gst0}]);
    
    Jac = SymExpression(zeros(6,nDof));
    Jac(:,indices) = Jz;
end