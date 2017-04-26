function base_link = findBaseLink(obj, joints)
    % Determines the base link of an array of rigid joints
    %
    % The base link is the link that is not a child link of any joints.
    %
    % Parameters:
    % joints: an array of rigid joints @type RigidJoint
    %
    % @note if 'joints' argument is not provided, it uses the default
    % 'Joints' property of the object.
    %
    % Return values:
    % base: the name of the base link @type char
    
    if nargin < 2
        joints = obj.Joints;
    end
    
    p_indices = str_indices({joints.Parent},{joints.Child},'UniformOutput',false);
    b_indices = cellfun(@isempty,p_indices);
    base_links = {joints(b_indices).Parent};
    
    if isempty(base_links)
        error('Unable to find the base link.');
    end
        
    n_base = length(base_links);
    if n_base > 1
        for i=1:n_base-1
            assert(strcmp(base_links{i},base_links{i+1}),...
                'Duplicated base links: %s and %s.\n',base_links{i},base_links{i+1});
        end
    end
    base_link = base_links{1};
end