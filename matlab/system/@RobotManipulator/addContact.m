function [h, cond] = addContact(obj, link, offset)
    % Adds contact constraints for the robot manipulator
    %
    % Parameters:
    %  link: the name of the rigid link on which the contact point is
    %  rigidly attached to @type char
    %  offset: the offset of the contact point from the origin of the
    %  link @type rowvec
    %
    % Return values:
    %  h: the holonomic constraints associated with the contacts 
    %  @type SymFunction
    %  cond: the unilateral conditions assoicated with the contacts 
    %  @type SymFunction
    %
    % @note each contact point is defined as a pair of the parent link name
    % and the offset of the contact point from the origon of the rigid link
    
    
    % validate input argument
    if iscell(contacts)
        assert(all(cellfun(@(x)isa(x,'KinematicContact'),contacts)),...
            'The input must be a cell array of objects of type ''KinematicContact''.');
    else
        assert(isa(contacts,'KinematicContact'),...
            'The input must be an object of type ''KinematicContact''.');
        contacts = {contacts};
    end
    
    
    % add to the holonomic constraints group
    obj.HolonomicConstr = addKinematic(obj.HolonomicConstr, contacts);
    
    % add to the unilateral constraints group
    
    % register associated unilateral constraints
    n_contact = numel(contacts);
    
    for i=1:n_contact
        
        %     % generate indices for associated constraint forces
        %     c_index = getIndex(obj.HolonomicConstr, contacts{i});
        
        % get the unilateral wrench constraints of the contact
        [names, constraints] = getWrenchConstraint(contacts{i});
        n_constr = numel(names);
        
        % create an empty table first
        nvars = size(obj.UnilateralConstr, 2);
        new_cond = cell2table(cell(n_constr,nvars),'VariableNames',...
            obj.UnilateralConstr.Properties.VariableNames);
        
        % set appropriate variables
        new_cond.Name = names;
        new_cond.WrenchCondition = constraints;
        %     new_cond.WrenchIndices(:) = {c_index};
        new_cond.Type(:) = {'Force'};
        new_cond.KinObject(:) = contacts(i);
        new_cond.KinName(:) = {contacts{i}.Name};
        new_cond.Properties.RowNames = new_cond.Name;
        
        % add to the existing unilateral condition table
        obj.UnilateralConstr = [obj.UnilateralConstr;new_cond];
        
        
        
        
        
    end
    
    
    
    
end
