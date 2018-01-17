function g = computeForwardKinematics(obj)
    % computes the forward kinematics transformation matrix of the
    % coordinate frame
    %
    % Return values:
    % g: the forward transformation matrix under the coordinate
    % system @type SymExpression
    
    frame = obj;
    while ~isprop(frame, 'TwistPairs') %isempty(frame.TwistPairs)
        frame = frame.Reference;
        if isempty(frame)
            error('The coordinate system is not fully defined.');
        end
    end
    
    twists = frame.TwistPairs;
    
    g = eval_math_fun('ForwardKinematics',[twists,{obj.gst0}]);
    
end