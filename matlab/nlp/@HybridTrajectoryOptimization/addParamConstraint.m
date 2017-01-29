function obj = addParamConstraint(obj, phase)
    % Add parameter consistency constraints within the phase 
    %
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    
    % extract phase information
    phase_idx = getPhaseIndex(obj, phase);
    phase_info = obj.Phase{phase_idx};
    phase_funcs = obj.Funcs.Phase{phase_idx};
    domain = obj.Gamma.Nodes.Domain{phase_info.CurrentVertex};
    % local variable for fast access
    n_node = phase_info.NumNode;
    var_table= phase_info.OptVarTable;
    col_names = phase_info.ConstrTable.Properties.VariableNames;
    
    if obj.Options.DistributeParamWeights
        if ~isempty(domain.DesVelocityOutput)
            v_cont = repmat({{}},1, n_node);
        end
        p_cont = repmat({{}},1, n_node);
        a_cont = repmat({{}},1, n_node);
        % domain admissible constraints are enforced at all nodes except the
        % last node
        node_list = 1:(n_node-1);
        
        for i=node_list
            %% parameters of velocity outputs
            if ~isempty(domain.DesVelocityOutput)
                v_cont{i} = {NlpFunction('Name','vCont',...
                    'Dimension',domain.DesVelocityOutput.NumParam, ...
                    'Type', 'linear', 'lb',0,'ub',0, ...
                    'DepVariables',{{var_table{'V',i}{1},var_table{'V',i+1}{1}}},...
                    'Funcs', phase_funcs.vCont.Funcs)};
            end
            
            %% phase variable parameters
            p_cont{i} = {NlpFunction('Name','pCont',...
                'Dimension',domain.PhaseVariable.Var.Parameters.Dimension, ...
                'Type', 'linear','lb',0,'ub',0,...
                'DepVariables', {{var_table{'P',i}{1},var_table{'P',i+1}{1}}},...
                'Funcs', phase_funcs.pCont.Funcs)};
            
            %% parameters of position outputs
            num_param = domain.DesPositionOutput.NumParam * ...
                getDimension(domain.ActPositionOutput);
            a_cont{i} = {NlpFunction('Name','aCont',...
                'Dimension',num_param, 'Type', 'linear',...
                'lb',0,'ub',0,...
                'DepVariables', {{var_table{'A',i}{1},var_table{'A',i+1}{1}}},...
                'Funcs', phase_funcs.aCont.Funcs)};
            
        end
        
        if ~isempty(domain.DesVelocityOutput)
            obj.Phase{phase_idx}.ConstrTable = [...
            obj.Phase{phase_idx}.ConstrTable;...
            cell2table(v_cont,'RowNames',{'vCont'},'VariableNames',col_names)];
        end
        
        obj.Phase{phase_idx}.ConstrTable = [...
            obj.Phase{phase_idx}.ConstrTable;...
            cell2table(p_cont,'RowNames',{'pCont'},'VariableNames',col_names);...
            cell2table(a_cont,'RowNames',{'aCont'},'VariableNames',col_names)];
    end
    
    % use same parameters for the same outputs in two neighboring domains
    if obj.Options.UseSameParameters
        if obj.Options.DistributeParamWeights
            param_node = n_node;
        else
            param_node = 1;
        end
        next_var_table = obj.Phase{obj.Phase{phase_idx}.NextVertex}.OptVarTable;
        next_domain = obj.Gamma.Nodes.Domain{obj.Phase{phase_idx}.NextVertex};
        
        if ~isempty(domain.DesVelocityOutput)
            v_phase_cont = repmat({{}},1, n_node);
        end
        p_phase_cont = repmat({{}},1, n_node);
        a_phase_cont = repmat({{}},1, n_node);
        %% parameters of velocity outputs
        if ~isempty(domain.DesVelocityOutput) && ~isempty(next_domain.DesVelocityOutput)
            v_phase_cont{param_node} = {NlpFunction('Name','vCont',...
                'Dimension',domain.DesVelocityOutput.NumParam, ...
                'Type', 'linear', 'lb',0,'ub',0, ...
                'DepVariables',{{var_table{'V',param_node}{1},next_var_table{'V',1}{1}}},...
                'Funcs', phase_funcs.vCont.Funcs)};
        end
        
        %% phase variable parameters
        p_phase_cont{param_node} = {NlpFunction('Name','pCont',...
            'Dimension',domain.PhaseVariable.Var.Parameters.Dimension, ...
            'Type', 'linear','lb',0,'ub',0,...
            'DepVariables', {{var_table{'P',param_node}{1},next_var_table{'P',1}{1}}},...
            'Funcs', phase_funcs.pCont.Funcs)};
        same_outputs = getPositionOutputIndex(domain,{next_domain.ActPositionOutput.KinGroupTable.Name});
        %% parameters of position outputs
        num_param = domain.DesPositionOutput.NumParam * length(same_outputs);
        a_phase_cont{param_node} = {NlpFunction('Name','aCont',...
            'Dimension',num_param, 'Type', 'linear',...
            'lb',0,'ub',0,...
            'DepVariables', {{var_table{'A',param_node}{1},next_var_table{'A',1}{1}}},...
            'Funcs', phase_funcs.aPhaseCont.Funcs)};
        
        if ~isempty(domain.DesVelocityOutput)
            obj.Phase{phase_idx}.ConstrTable = [...
                obj.Phase{phase_idx}.ConstrTable;...
            cell2table(v_phase_cont,'RowNames',{'vPhaseCont'},'VariableNames',col_names)];
        end
        
        obj.Phase{phase_idx}.ConstrTable = [...
            obj.Phase{phase_idx}.ConstrTable;...
            cell2table(p_phase_cont,'RowNames',{'pPhaseCont'},'VariableNames',col_names);...
            cell2table(a_phase_cont,'RowNames',{'aPhaseCont'},'VariableNames',col_names)];
    end
end