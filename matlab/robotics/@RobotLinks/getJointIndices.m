function indices = getJointIndices(obj, joint_names)
    % Returns the indices of joints specified by the name string
    %
    % Parameters:
    %  joint_names: a cell array of strings of the DoF name
    %
    % Return values:
    %  indices: position indices of joints in the obj.joints
    % 
    % @see getLinkIndices, joints
    
    
    all_joint_names = {obj.Joints.Name};
    
    
    
    if iscellstr(joint_names) 
        nj = numel(joint_names);
    
        indices = zeros(nj,1);
        
        for i=1:nj
            index = str_index(all_joint_names,joint_names{i});
            if isempty(index)
                warning('the joint %s not exists.', joint_names{i});
                indices(i) = NaN;
            else
                indices(i) = index;
            end
            
        end
    elseif ischar(joint_names)
        % specified only one joint
        indices = str_index(all_joint_names,joint_names);
        if isempty(indices)
            warning('the joint %s not exists.', joint_names);
            indices = NaN;
        end
    else
        error('please provide correct information (Joint Name)');
    end
    
    
end
