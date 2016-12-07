function obj = addContact(obj, contacts)
% Adds a contact constraint for the domain
%
% Parameters:
%  contacts: a cell array of kinematic contacts @type KinematicContact


% validate input argument
if iscell(contacts)
    assert(all(cellfun(@(x)isa(x,'KinematicContact'),contacts)),...
        'The input must be a cell array of objects of type ''KinematicContact''.');
else
    assert(isa(contacts,'KinematicContact'),...
        'The input must be an object of type ''KinematicContact''.');
    contacts = {contacts};
end
    

n_contact = numel(contacts);

for i=1:n_contact
    
    % first add to the holonomic constraints array
    obj.HolonomicConstr(end+1) = contacts(i);
    
    % generate indices for associated constraint forces
    dim_c = getDimension(contacts{i});
    c_index = obj.DimensionHolonomic + cumsum(ones(1,dim_c));
    
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
    new_cond.WrenchIndices(:) = {c_index};    
    new_cond.Type(:) = {'Force'};
    
    % add to the existing unilateral condition table
    obj.UnilateralConstr = [obj.UnilateralConstr;new_cond];
    
    
end


end
