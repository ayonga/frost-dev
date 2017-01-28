function pos = getPosition(obj, kin)
    % Returns the position of the kinematic object in the group
    %
    % Parameters:
    % kin: the name of the kinematic object or the kinematic object
    % @type char



    if ischar(kin)
        pos = find(strcmp(kin, {obj.KinGroupTable.Name}));
        
        %         if isempty(pos)
        %             error('The kinematic object: %s cannot be found in the group.\n',...
        %                 kin);
        %         end
    elseif isa(kin,'Kinematics')
        pos = find(strcmp(kin.Name, {obj.KinGroupTable.Name}));
        
        %         if isempty(pos)
        %             error('The kinematic object: %s cannot be found in the group.\n',...
        %                 kin.Name);
        %         end
    end


end