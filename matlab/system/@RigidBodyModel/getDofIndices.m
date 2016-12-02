function indices = getDofIndices(obj, dof_names)
    % Returns the indices of joints specified by the name string
    %
    % Parameters:
    %  dof_names: a cell array of strings of the DoF name
    %
    % Return values:
    %  indices: position indices of joints in the obj.joints
    % 
    % @see getLinkIndices, joints
    
    
    all_dof_names = {obj.dofs.name};
    
    
    
    if iscell(dof_names) 
        nj = numel(dof_names);
    
        indices = zeros(nj,1);
        
        for i=1:nj
            index = str_index(all_dof_names,dof_names{i});
            if isempty(index)
                warning('the joint %s not exists.', dof_names{i});
                indices(i) = NaN;
            else
                indices(i) = index;
            end
            
        end
    elseif ischar(dof_names)
        % specified only one joint
        indices = str_index(all_dof_names,dof_names);
    else
        error('please provide correct information (Joint Name)');
    end
    
    
end
