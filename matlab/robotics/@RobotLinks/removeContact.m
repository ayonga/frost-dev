function obj = removeContact(obj, contact)
    % Remove contact constraints defined for the system
    %
    % Parameters:
    % contact: the name of the contact @type cellstr
    
    % validate the input argument
    if ischar(contact)
        contact_name = {contact};
    elseif isa(contact, 'ContactFrame')
        contact_name = {contact.Name};
    elseif iscell(contact)
        contact_name = cell(numel(contact),1);
        for i=1:numel(contact)
            c = contact{i};
            if ischar(c)
                contact_name{i} = c;
            elseif isa(c, 'ContactFrame')
                contact_name{i} = c.Name;
            else
                error('You must provide the name of the contact or the ContactFrame object.')
            end
        end
    else
        error('You must provide the name of the contact or the ContactFrame object.')
    end
    
    
    for i=1:length(contact_name)
        name = contact_name{i};
        
        % remove the associated holonomic constraints
        obj.removeHolonomicConstraint(name);
        
        % remove the associated unilateral constraints
        % 1. friction cone
        fc_cstr = ['fc', name];
        if isfield(obj.UnilateralConstraints, fc_cstr)
            obj.removeUnilateralConstraint(fc_cstr);
        end
        % 2. ZMP constraints
        zmp_cstr = ['zmp', name];
        if isfield(obj.UnilateralConstraints, zmp_cstr)
            obj.removeUnilateralConstraint(zmp_cstr);
        end
    end
end