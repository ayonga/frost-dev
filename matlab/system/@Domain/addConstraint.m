function obj = addConstraint(obj, constr_list)
    % Adds holonomic constraints for the domain
    %
    % Parameters:
    %  constr_list: a cell array of new holonomic constraints @type
    %  cell
    
    % validate holonomic constraints
    
    if any(cellfun(@(x) ~isa(x,'Kinematics'),constr_list))
        error('Domain:invalidConstr', ...
            'There exist non-Kinematics objects in the list.');
    end
    
    obj.hol_constr = horzcat(obj.hol_constr, constr_list);
    
    % updates the list of names and dimention
    obj.hol_constr_names = cellfun(@(x) x.name, obj.hol_constr,'UniformOutput',false);
    obj.n_hol_constr = length(obj.hol_constr);
end
