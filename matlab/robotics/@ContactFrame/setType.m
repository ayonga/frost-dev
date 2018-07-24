function obj = setType(obj, type)
    % Sets the contact type
    %
    % Parameters:
    % type: the contact type @type char
    
    
    valid_types = {'PlanarLineContactWithFriction',...
        'PlanarPointContactWithFriction',...
        'PointContactWithFriction',...
        'PointContactWithoutFriction',...
        'LineContactWithFriction',...
        'LineContactWithoutFriction',...
        'PlanarContactWithFriction',...
        'PlanarContactWithoutFriction'};
    
    obj.Type = validatestring(type,valid_types);
    
    I = eye(6);
    switch obj.Type
        case 'PlanarLineContactWithFriction'
            % x, z
            obj.WrenchBase = I(:,[1,3,5]);
        case 'PlanarPointContactWithFriction'
            % x, z
            obj.WrenchBase = I(:,[1,3]);
        case 'PointContactWithFriction'
            % x, y, z
            obj.WrenchBase = I(:,[1,2,3]);
        case 'PointContactWithoutFriction'
            % z
            obj.WrenchBase = I(:,3);
        case 'LineContactWithFriction'
            % x, y, z, roll, yaw
            obj.WrenchBase = I(:,[1,2,3,4,6]);
        case 'LineContactWithoutFriction'
            % z, roll
            obj.WrenchBase = I(:,[3,6]);
        case 'PlanarContactWithFriction'
            % x, y, z, roll, pitch, yaw
            obj.WrenchBase = I(:,[1,2,3,4,5,6]);
        case 'PlanarContactWithoutFriction'
            % z, roll, pitch,
            obj.WrenchBase = I(:,[3,4,5]);
    end
    
end