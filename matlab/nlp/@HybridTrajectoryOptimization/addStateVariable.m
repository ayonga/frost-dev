function obj = addStateVariable(obj, phase)
    % Adds state variables as the NLP decision variables to the problem
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    
    phase_idx = getPhaseIndex(obj, phase);
    phase_info = obj.Phase{phase_idx};


    n_node = phase_info.NumNode;
    col_names = phase_info.OptVarTable.Properties.VariableNames;

    model = obj.Model;
    
    % state variables are defined at all collocation nodes
    node_list = 1:1:n_node;
    q = repmat({{}},1, n_node);
    dq = repmat({{}},1, n_node);
    ddq = repmat({{}},1, n_node);
    
    for i=node_list
        % joint (q)
        q{i} = {NlpVariable('Name', 'q', 'Dimension', model.nDof, ...
            'lb', [model.Dof.lower]', ...
            'ub', [model.Dof.upper]')};
        % joint velocity (dq)
        dq{i} = {NlpVariable('Name', 'dq', 'Dimension', model.nDof, ...
            'lb', -[model.Dof.velocity]', ...
            'ub', [model.Dof.velocity]')};
        
        % joint acceleration (ddq)
        ddq{i} = {NlpVariable('Name', 'ddq', 'Dimension', model.nDof, ...
            'lb', -1e4, ...
            'ub', 1e4)};
        
    end
    
    
    % add to the decision variable table
    obj.Phase{phase_idx}.OptVarTable = [...
        obj.Phase{phase_idx}.OptVarTable;...
        cell2table(q,'VariableNames',col_names,'RowNames',{'Qe'});...
        cell2table(dq,'VariableNames',col_names,'RowNames',{'dQe'});...
        cell2table(ddq,'VariableNames',col_names,'RowNames',{'ddQe'})];


end