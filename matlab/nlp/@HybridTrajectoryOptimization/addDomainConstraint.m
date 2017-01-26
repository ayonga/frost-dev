function obj = addDomainConstraint(obj, phase)
    % Add generic domain-admissibility constraints
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    
    % extract phase information
    phase_idx = getPhaseIndex(obj, phase);
    phase_info = obj.Phase{phase_idx};
    phase_funcs = obj.Funcs.Phase{phase_idx};
    
    % local variable for fast access
    n_node = phase_info.NumNode;
    var_table= phase_info.OptVarTable;
    col_names = phase_info.ConstrTable.Properties.VariableNames;
    
    domain = phase_info.Domain;
    
    force_constr = repmat({{}},1, n_node);
    kin_constr   = repmat({{}},1, n_node);
    
    err_bound = obj.Options.EqualityBoundRelaxFactor;
    
    % domain admissible constraints are enforced at all nodes
    node_list = 1:n_node;
    for i=node_list
        
        force_cond_table = domain.UnilateralConstr(strcmp(domain.UnilateralConstr.Type,'Force'),:);
        
%         if ~isempty(force_cond_table)      
%             n_cond = sum(cellfun(@(x)size(x,1),force_cond_table.WrenchCondition));
%             % v(Fe) > 0
%             force_constr{i} = {NlpFunction('Name','zmp',...
%                 'Dimension',n_cond, 'Type', 'linear',...
%                 'lb',0,'ub',inf, 'DepVariables', {{var_table{'Fe',i}{1}}},...
%                 'Funcs', phase_funcs.zmp.Funcs)};
%             
%             
%         end
        
        
        kin_cond_table = domain.UnilateralConstr(strcmp(domain.UnilateralConstr.Type,'Kinematic'),:);
        if ~isempty(kin_cond_table)
            n_cond = sum(cellfun(@(x)getDimension(x),kin_cond_table.KinObject));
            % v(q) > 0
            kin_constr{i} = {NlpFunction('Name','kinUnilateral',...
                'Dimension',n_cond, 'Type', 'nonlinear',...
                'lb',0,'ub',inf,'DepVariables', {{var_table{'Qe',i}{1}}},...
                'Funcs', phase_funcs.kinUnilateral.Funcs)};
            
            
        end
       
    end
    
    % add to the constraints table
    if ~isempty(force_cond_table)  
        obj.Phase{phase_idx}.ConstrTable = [...
            obj.Phase{phase_idx}.ConstrTable;...
            cell2table(force_constr,'RowNames',{'zmp'},'VariableNames',col_names)];
    end
    
    
    % add to the constraints table
    if ~isempty(kin_cond_table)
        obj.Phase{phase_idx}.ConstrTable = [...
            obj.Phase{phase_idx}.ConstrTable;...
            cell2table(kin_constr,'RowNames',{'kinUnilateral'},'VariableNames',col_names)];
    end
    
    
end