function obj = removeContact(obj, contacts)
    % Removes holonomic kinematic constraints other than contact constraints
    % from the domain
    %
    % Parameters:
    %  kins: a cell array of kinematic objects or name string @type Kinematic




    % remove from the holonomic constraints group
    obj.HolonomicConstr = removeKinematic(obj.HolonomicConstr, contacts);

    % remove from the unilateral table
    if ischar(contacts)
        contacts = {contacts};
    elseif isscalar(contacts) && ~iscell(contacts)
        contacts = {contacts};
    end

    for i=1:numel(contacts)
        if ischar(contacts{i})
            obj.UnilateralConstr(strcmp(obj.UnilateralConstr.KinName,contacts{i}),:) = [];
        elseif isa(contacts{i},'Kinematics')
            obj.UnilateralConstr(strcmp(obj.UnilateralConstr.KinName,contacts{i}.Name),:) = [];
        end
    end
end
