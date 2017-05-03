function xi = getTwist(obj)
    % returns the twist vector of the rigid joint
    %
    %
    
    assert(~isempty(obj.Type),'The joint type is undefined.');
    assert(~isempty(obj.Axis),'The joint axis is undefined.');
    
    switch obj.Type
        case 'prismatic'
            xi = [obj.Axis,zeros(1,3)];
        case {'revolute','continuous','fixed'}
            xi = [zeros(1,3),obj.Axis];
    end
    
    
end