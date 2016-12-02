function indices = getLinkIndices(obj, link_names)
    % Returns the indices of links specified by the name string
    %
    % Parameters:
    %  link_names: a cell array of strings of the link name
    %
    % Return values:
    %  indices: position indices of joints in the obj.joints
    
    
    all_link_name = {obj.links.name};
    
    if iscell(link_names)
        nl = numel(link_names);
        
        indices = zeros(nl,1);
        
        for k=1:nl
            l_index = str_index(all_link_name,link_names{k});
            if isempty(l_index)
                warning('the link %s not exists.', link_names{k});
                indices(k) = NaN;
            else
                indices(k) = l_index;
            end
            
        end
    elseif ischar(link_names)
        % specified only one joint
        indices = str_index(all_link_name,link_names);
    else
        error('please provide correct information (Link Name)');
    end
end
