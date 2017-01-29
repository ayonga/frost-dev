function obj = addOutputConstraint(obj, phase)
    % Add output dynamics associated with domain virtual constraints as a
    % set of equality constraints
    %
    % The output dynamics equations are enforced to determine the feedback
    % control law via virtual constraints. In order to have hybrid zero
    % dynamics, relative degree two outputs should have initial value of
    % zeros at the first node.
    % \f{eqnarray*}{
    %  \dot{y}_1(q,\dot{q},\ddot{q},v,p) + \epsilon * y_1(q,\dot{q},v,p) &= 0\\
    %  \ddot{y}_2(q,\dot{q},\ddot{q},a,p) + 2*\epsilon * \dot{y}_2(q,\dot{q},a,p) + \epsilon^2 * y_2(q,a,p)&= 0
    % \f}
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    
    % extract phase information
    phase_idx = getPhaseIndex(obj, phase);
    phase_info = obj.Phase{phase_idx};
    phase_funcs = obj.Funcs.Phase{phase_idx};
    domain = obj.Gamma.Nodes.Domain{phase_info.CurrentVertex};
    
    if ~isempty(domain.ActVelocityOutput)
        n_vel_output = getDimension(domain.ActVelocityOutput);
    else
        n_vel_output = 0;
    end
    n_pos_output = getDimension(domain.ActPositionOutput);
    % local variable for fast access
    n_node = phase_info.NumNode;
    var_table= phase_info.OptVarTable;
    col_names = phase_info.ConstrTable.Properties.VariableNames;
    
    
    y1Vel = repmat({{}},1, n_node);
    y1Acc = repmat({{}},1, n_node);
    y2Pos = repmat({{}},1, n_node);
    y2Vel = repmat({{}},1, n_node);
    y2Acc = repmat({{}},1, n_node);
    
    % output dynamics constraints are enforced at all nodes

    err_bound = obj.Options.EqualityBoundRelaxFactor;
    
    node_list = 1:n_node;
    for i=node_list
        
        if obj.Options.DistributeParamWeights
            node_param = i;
        else
            node_param = 1;
        end
        
        if n_vel_output > 0  
            % y1dot(q,dq,ddq,v,p) + epsilon*y1(q,dq,v,p) = 0
            y1Acc{i} = {NlpFunction('Name','y1Acc',...
                'Dimension',n_vel_output, 'Type', 'nonlinear',...
                'lb',-err_bound,'ub',err_bound, 'DepVariables', ...
                {{var_table{'Qe',i}{1},var_table{'dQe',i}{1},var_table{'ddQe',i}{1},...
                var_table{'P',node_param}{1},var_table{'V',node_param}{1}}},...
                'Funcs',phase_funcs.y1Acc.Funcs)};
        end
        
        % y2ddot(q,dq,ddq,a,p) + 2*epsilon*y2dot(q,dq,a,p) + epsilon*y2(q,dq,v,p) = 0
        y2Acc{i} = {NlpFunction('Name','y2Acc',...
            'Dimension',n_pos_output, 'Type', 'nonlinear',...
            'lb',-err_bound,'ub',err_bound, 'DepVariables', ...
            {{var_table{'Qe',i}{1},var_table{'dQe',i}{1},var_table{'ddQe',i}{1},...
            var_table{'P',node_param}{1},var_table{'A',node_param}{1}}},...
            'Funcs', phase_funcs.y2Acc.Funcs)};
    end
    
    % initial value constraints on position/velocity of virtual constraints
    % to ensure the system lies on the hybrid zero dynamics surface
    if n_vel_output > 0
        if obj.Options.ZeroVelocityOutputError
            % y1(q,dq,v,p) = 0
            y1Vel{1} = {NlpFunction('Name','y1Vel',...
                'Dimension',n_vel_output, 'Type', 'nonlinear',...
                'lb',-err_bound,'ub',err_bound,...
                'DepVariables', {{var_table{'Qe',1}{1},var_table{'dQe',1}{1},...
                var_table{'P',1}{1},var_table{'V',1}{1}}},...
                'Funcs', phase_funcs.y1Vel.Funcs)};
        end
    end
    
    % y2(q,a,p) = 0
    y2Pos{1} = {NlpFunction('Name','y2Pos',...
        'Dimension',n_pos_output, 'Type', 'nonlinear',...
        'lb',-err_bound,'ub',err_bound,...
        'DepVariables',{{var_table{'Qe',1}{1},var_table{'P',1}{1},...
        var_table{'A',1}{1}}},...
        'Funcs', phase_funcs.y2Pos.Funcs)};
    
    % dy2(q,dq,a,p) = 0
    y2Vel{1} = {NlpFunction('Name','y2Vel',...
        'Dimension',n_pos_output, 'Type', 'nonlinear',...
        'lb',-err_bound,'ub',err_bound,...
        'DepVariables',{{var_table{'Qe',1}{1},var_table{'dQe',1}{1},...
        var_table{'P',1}{1},var_table{'A',1}{1}}},...
        'Funcs',phase_funcs.y2Vel.Funcs)};
    
    
    % add to the constraints table
    if n_vel_output > 0
        obj.Phase{phase_idx}.ConstrTable = [...
            obj.Phase{phase_idx}.ConstrTable;...
            cell2table(y1Vel,'RowNames',{'y1Vel'},'VariableNames',col_names);...
            cell2table(y1Acc,'RowNames',{'y1Acc'},'VariableNames',col_names);...
            cell2table(y2Pos,'RowNames',{'y2Pos'},'VariableNames',col_names);...
            cell2table(y2Vel,'RowNames',{'y2Vel'},'VariableNames',col_names);...
            cell2table(y2Acc,'RowNames',{'y2Acc'},'VariableNames',col_names)];
    else
        obj.Phase{phase_idx}.ConstrTable = [...
            obj.Phase{phase_idx}.ConstrTable;...
            cell2table(y2Pos,'RowNames',{'y2Pos'},'VariableNames',col_names);...
            cell2table(y2Vel,'RowNames',{'y2Vel'},'VariableNames',col_names);...
            cell2table(y2Acc,'RowNames',{'y2Acc'},'VariableNames',col_names)];
    end
end