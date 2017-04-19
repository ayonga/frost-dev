function pos = getComPosition(obj)
    % Returns the symbolic representation of the robot manipulator
    %
    % Return values:
    % pos: the 3-Dimensional SO(3) position vector of the CoM of the system
    % @type SymExpression
    
    
    
    
    n_link = length(obj.Links);
    links = cell(1,n_link);
    for i=1:n_link
        links{i}.Mass = obj.Links(i).Mass;
        % links{i}.Inertia = obj.Links(i).Inertia;        
        links{i}.gst0 = obj.Links(i).gst0;
        frame = obj.Links(i).Reference;
        while isempty(frame.TwistPairs)
            frame = frame.Reference;
            if isempty(frame)
                error('The coordinate system is not fully defined.');
            end
        end
        
        links{i}.TwistPairs = frame.TwistPairs;
        % links{i}.ChainIndices = frame.ChainIndices;
    end
    
    pos = eval_math_fun('ComputeComPosition',links);
    
end