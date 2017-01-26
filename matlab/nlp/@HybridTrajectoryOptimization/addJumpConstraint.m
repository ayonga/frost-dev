function obj = addJumpConstraint(obj, phase)
    % Add generic switching surface constraints, including guard condition
    % and reset map constraints
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
    
    n_dof = obj.Model.nDof;
    
    domain = phase_info.Domain;    
    guard = phase_info.Guard;
    
    next_var_table = obj.Phase{obj.Phase{phase_idx}.NextVertex}.OptVarTable;
    
    err_bound = obj.Options.EqualityBoundRelaxFactor;
    
    guard_con = repmat({{}},1, n_node);
    q_resetmap = repmat({{}},1, n_node);
    dq_resetmap = repmat({{}},1, n_node);
    
    % the guard condition is enforced at the last node
    guard_cond = domain.UnilateralConstr(guard.Condition,:);
    
    
    switch guard_cond.Type{1}
        case 'Kinematic'
            guard_con{n_node} = {NlpFunction('Name','guard',...
                'Dimension',1, 'lb',-err_bound,'ub',err_bound, 'Type', 'nonlinear',...
                'DepVariables', {{var_table{'Qe',n_node}{1}}},...
                'AuxData', 0,...
                'Funcs', phase_funcs.guard_func.Funcs)};
        case 'Force'
            guard_con{n_node} = {NlpFunction('Name','guard',...
                'Dimension',1, 'lb',-err_bound,'ub',err_bound, 'Type', 'linear',...
                'DepVariables', {{var_table{'Fe',n_node}{1}}},...
                'Funcs', phase_funcs.guard_func.Funcs)};
            
        otherwise
            error('Unrecognized guard type.');
    end
    
    obj.Phase{phase_idx}.ConstrTable = [...
        obj.Phase{phase_idx}.ConstrTable;...
        cell2table(guard_con,'RowNames',{'guard'},'VariableNames',col_names)];
    
    
    q_resetmap{n_node} = {NlpFunction('Name','qResetMap',...
        'Dimension',n_dof, 'Type', 'linear', 'lb',-err_bound,'ub',err_bound,...
        'DepVariables',{{var_table{'Qe',n_node}{1},next_var_table{'Qe',1}{1}}},...
        'Funcs', phase_funcs.qResetMap.Funcs)};
    
    if guard.DeltaOpts.ApplyImpact
        dq_resetmap{n_node} = {NlpFunction('Name','dqResetMap',...
            'Dimension',n_dof, 'Type', 'nonlinear', 'lb',-err_bound,'ub',err_bound,...
            'DepVariables',{{var_table{'Qe',n_node}{1},var_table{'dQe',n_node}{1},...
            var_table{'Fi',n_node}{1},next_var_table{'Qe',1}{1}}},...
            'Funcs', phase_funcs.dqResetMap.Funcs)};
    else
        dq_resetmap{n_node} = {NlpFunction('Name','dqResetMap',...
            'Dimension',n_dof, 'Type', 'linear', 'lb',-err_bound,'ub',err_bound,...
            'DepVariables',{{var_table{'dQe',n_node}{1},next_var_table{'dQe',1}{1}}},...
            'Funcs', phase_funcs.dqResetMap.Funcs)};        
    end
    
    
    obj.Phase{phase_idx}.ConstrTable = [...
        obj.Phase{phase_idx}.ConstrTable;...
        cell2table(q_resetmap,'RowNames',{'qResetMap'},'VariableNames',col_names);...
        cell2table(dq_resetmap,'RowNames',{'dqResetMap'},'VariableNames',col_names)];
end