function obj = removeUnilateralConstraint(obj, kins)
    % Removes unilateral kinematic constraints other than contact constraints
    % from the domain
    %
    % Parameters:
    %  kins: a cell array of kinematic objects or name string @type Kinematic




    % remove from the unilateral constraint table
    if ischar(kins)
        kins = {kins};
    elseif isscalar(kins) && ~iscell(kins)
        kins = {kins};
    end

    for i=1:numel(kins)
        if ischar(kins{i})
            obj.UnilateralConstr(strcmp(obj.UnilateralConstr.KinName,kins{i}),:) = [];
        elseif isa(kins{i},'Kinematics')
            obj.UnilateralConstr(strcmp(obj.UnilateralConstr.KinName,kins{i}.Name),:) = [];
        end
    end


end
