function index = getIndex(obj, kin)
    % Returns the index of the kinematic object in the group
    %
    % Parameters:
    % kin: the name of the kinematic object or the kinematic object
    % @type char



    pos = getPosition(obj, kin);
    if isempty(pos)
        index = [];
    else
        index = obj.KinGroupTable(pos).Index;
    end

end