function obj = removeKinematic(obj, kin)
    % remove kinematic objects from the group
    %
    % Parameters:
    % kin: one or a group of kinematic objects or names to be removed from the
    % existing group @type Kinematics

    if ischar(kin)
        kin = {kin};
    elseif isscalar(kin) && ~iscell(kin)
        kin = {kin};
    end

    assert(iscell(kin),...
        'The input argument must be a scalar or a cell array');

    for i=1:numel(kin)
        if ischar(kin{i})
            ind = find(strcmp(kin{i}, {obj.KinGroupTable.Name}));
            if isempty(ind)
                warning('The kinematic object: %s cannot be found in the group.\nSkipping...\n',...
                    kin{i});
                continue;
            end
            obj.KinGroupTable(ind) = [];
        elseif isa(kin{i},'Kinematics')
            ind = find(strcmp(kin{i}.Name, {obj.KinGroupTable.Name}));
            if isempty(ind)
                warning('The kinematic object: %s cannot be found in the group.\nSkipping...\n',...
                    kin{i}.Name);
                continue;
            end
            obj.KinGroupTable(ind) = [];
        end

    end

    % update the indexing information
    obj = updateIndex(obj);
end