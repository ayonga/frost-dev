function obj = addHolonomicConstraint(obj, constr_list)
    % Adds holonomic constraints for the domain
    %
    % Parameters:
    %  constr_list: a cell array of new holonomic constraints @type
    %  Kinematics
    
    % validate holonomic constraints
    
    if any(cellfun(@(x) ~isa(x,'Kinematics'), constr_list))
        error('Domain:invalidType', ...
            'There exist non-Kinematics objects in the list.');
    end
    
    obj.hol_constr = horzcat(obj.hol_constr, constr_list);
    
    for i=1:numel(constr_list)
        constr = constr_list{i};
        
        if isa(constr,'KinematicContact')
            
            new_con = {constr.name, 'force', 
            
            
            
        end
        
    end
end
