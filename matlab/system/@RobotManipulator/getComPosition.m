function pos = getComPosition(obj)
    % Returns the symbolic representation of the robot manipulator
    %
    % Return values:
    % pos: the 3-Dimensional SO(3) position vector of the CoM of the system
    % @type SymExpression
    
    pos = eval_math_fun('ComputeComPosition',{obj.SymLinks,obj.SymTwists});
    
end