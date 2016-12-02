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
        
        indices_c = str_indices(link_names,all_link_name,'UniformOutput',false);
        
        links_not_found = find(cellfun('isempty',indices_c), 1);
        
        if isempty(links_not_found)
           warning('the following links not exists.');
           for k = 1:length(links_not_found)
               disp('%s, ',link_names{links_not_found(k)});
               indices_c(links_not_found(k)) = NaN;
           end
        end
        indices = [indices_c{:}];
        
    elseif ischar(link_names)
        % specified only one joint
        indices = str_index(all_link_name,link_names);
    else
        error('please provide correct information (Link Name)');
    end
end
