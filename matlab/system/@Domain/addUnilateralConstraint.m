function obj = addUnilateralConstraint(obj, kins)
    % Adds unilateral kinematic constraints other than contact constraints to
    % the domain
    %
    % Parameters:
    %  kins: a cell array of kinematic constraints @type Kinematic


    % validate input argument
    if iscell(kins)
        assert(all(cellfun(@(x)isa(x,'Kinematics')&&~isa(x,'KinematicContact'),kins)),...
            ['The input must be a cell array of objects of type ''Kinematics'' other than ''KinematicContact''\n. '...
            'To add contact constraints, please use %s'], 'KinematicContact');
    else
        assert(isa(kins,'Kinematics')&&~isa(kins,'KinematicContact'),...
            ['The input must be a cell array of objects of type ''Kinematics'' other than ''KinematicContact''\n. '...
            'To add contact constraints, please use %s'], 'KinematicContact');
        kins = {kins};
    end


    n_kin = numel(kins);
    
    for i=1:n_kin
        % create an empty table first
        nvars = size(obj.UnilateralConstr, 2);

        dim_c = getDimension(kins{i});
        new_cond = cell2table(cell(dim_c,nvars),'VariableNames',...
            obj.UnilateralConstr.Properties.VariableNames);
        new_cond.Name = {kins{i}.Name};
        new_cond.Type = {'Kinematic'};
        new_cond.KinObject = kins(i);
        new_cond.KinName = kins{i}.Name;
        new_cond.Properties.RowNames = new_cond.Name;
        % add to the existing unilateral condition table
        obj.UnilateralConstr = [obj.UnilateralConstr;new_cond];
    end
end
