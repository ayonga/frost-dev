function indices = getJointIndices(obj, joint_names, with_base)
    % Returns the indices of joints specified by the name string
    %
    % Parameters:
    %  joint_names: a cell array of strings of the joint name
    %
    % Return values:
    %  indices: position indices of joints in the obj.joints
    % 
    % @see getLinkIndices, joints
    
    if nargin < 3
        with_base = false;
    end
    
    all_joint_name = {obj.joints.name};
    
    
    
    if iscell(joint_names) 
        nj = numel(joint_names);
    
        indices = zeros(nj,1);
        
        for i=1:nj
            index = str_index(all_joint_name,joint_names{i});
            if isempty(index)
                warning('the joint %s not exists.', joint_names{i});
                indices(i) = NaN;
            else
                indices(i) = index;
            end
            
        end
    elseif ischar(joint_names)
        % specified only one joint
        indices = str_index(all_joint_name,joint_name);
    else
        error('please provide correct information (Joint Name)');
    end
    
    if with_base
        indices = obj.nBase + indices;
    end
end