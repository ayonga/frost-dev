function index = getIndex(obj, kin)
    % Returns the index of the kinematic object in the group
    %
    % Parameters:
    % kin: the name of the kinematic object or the kinematic object
    % @type char



    if ischar(kin)
        ind = find(strcmp(kin, {obj.KinGroupTable.Name}));
    elseif isa(kin,'Kinematics')
        ind = find(strcmp(kin.Name, {obj.KinGroupTable.Name}));
    end

    if isempty(ind)
        warning('The kinematic object: %s cannot be found in the group.\nSkipping...\n',...
            kin.Name);
        index = [];
    else
        index = obj.KinGroupTable(ind);
    end

end