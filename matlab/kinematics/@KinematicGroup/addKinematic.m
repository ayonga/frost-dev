function obj = addKinematic(obj, kin)
    % add kinematic objects to the group
    %
    % Parameters:
    % kin: one or a group of kinematic objects to be added to the
    % existing group @type cell

    if isscalar(kin) && ~iscell(kin)
        kin = {kin};
    end

    assert(iscell(kin),...
        'The input argument must be a scalar or a cell array');

    % validate dependent arguments
    check_object = @(x) ~isa(x,'Kinematics');

    if any(cellfun(check_object,kin))
        error('Kinematics:invalidObject', ...
            'There exist non-Kinematics objects in the variable list.');
    end

    num_kin = length(obj.KinGroupTable);

    for i=1:numel(kin)
        
        if ~obj.AllDuplicate
            if any(strcmp(kin{i}.Name,{obj.KinGroupTable.Name}))
                warning('The kinematic object: %s already exists in the group.\nSkipping...\n',...
                    kin{i}.Name);
                continue;
            end
        end

        % record the name and kinematic object
        obj.KinGroupTable(i+num_kin).Name = kin{i}.Name;
        obj.KinGroupTable(i+num_kin).KinObj = kin{i};
        obj.KinGroupTable(i+num_kin).Index = [];

    end

    % update the indexing information
    obj = updateIndex(obj);
end