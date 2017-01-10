function obj = updateIndex(obj)
    % Generates indices for the kinematic objects in the group

    k_ind = 0;
    for i=1:numel(obj.KinGroupTable)
        % generate index
        k_dim = getDimension(obj.KinGroupTable(i).KinObj);
        obj.KinGroupTable(i).Index = k_ind + cumsum(ones(1,k_dim));

        % update offset
        k_ind = k_ind + k_dim;
    end
end