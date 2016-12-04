function obj = removeConstraint(obj, constr_list)
    % Removes holonomic constraints from the defined holonomic
    % constraints of the domain
    %
    % Parameters:
    %  constr_list: a cell array of holonomic constraints to be
    %  removed @type cell
    
    if any(cellfun(@(x) ~isa(x,'Kinematics'),constr_list))
        error('Domain:invalidConstr', ...
            'There exist non-Kinematics objects in the list.');
    end
    
    remove_constr_name = cellfun(@(x) x.name,constr_list,'UniformOutput',false);
    
    kin_indices = str_indices(remove_constr_name,obj.hol_constr_names);
    
    
    if isempty(kin_indices)
        warning('None of the given constraint defined on this domain. Aborting ...');
        return;
    end
    
    all_indices = cumsum(ones(1,obj.n_hol_constr));
    % set indices of removing consntraints to be zero
    all_indices(kin_indices) = 0;
    % find non-zero indices
    if ~any(all_indices) % if all zeros
        obj.hol_constr = {};
        % updates the list of names and dimention
        obj.hol_constr_names = {};
        obj.n_hol_constr = 0;
    else
        obj.hol_constr = obj.hol_constr(all_indices~=0);
        % updates the list of names and dimention
        obj.hol_constr_names = cellfun(@(x) x.name, obj.hol_constr,'UniformOutput',false);
        obj.n_hol_constr = length(obj.hol_constr);
    end
    
end
