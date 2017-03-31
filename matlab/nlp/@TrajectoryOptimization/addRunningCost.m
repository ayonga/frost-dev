function obj = addRunningCost(obj, func)
    % Add a running cost to the problem
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    % func: a symbolic function to be integrated @type SymFunction
    %
    % @todo complete the implementation for other schemes
    
    assert(isa(func,'SymFunction'),...
        'The second argument must be a SymFunction.');
    
    phase_idx = getPhaseIndex(obj, phase);
    phase_info = obj.Phase{phase_idx};


    n_node = phase_info.NumNode;
    col_names = phase_info.CostTable.Properties.VariableNames;
    var_table= phase_info.OptVarTable;
    cost  = repmat({{}},1, n_node);
    
    
    cost_terminal = SymFunction('Name',[func.Name,'_terminal'],...
        'Expression',['((T/(nNode-1))/6)*',func.Expression]);
    cost_terminal = setDepSymbols(cost_terminal, [{'T'},func.DepSymbols]);
    cost_terminal = setPreCommands(cost_terminal, func.PreCommands);
    cost_terminal = setDescription(cost_terminal, [func.Description,'(terminal)']);
    cost_terminal = setParSymbols(cost_terminal,{'nNode'});
    obj.Funcs.Phase{phase_idx}.([func.Name,'_terminal']) = cost_terminal;
    
    cost_interior = SymFunction('Name',[func.Name,'_interior'],...
        'Expression',['(2(T/(nNode-1))/3)*',func.Expression]);
    cost_interior = setDepSymbols(cost_interior, [{'T'},func.DepSymbols]);
    cost_interior = setPreCommands(cost_interior, func.PreCommands);
    cost_interior = setDescription(cost_interior, [func.Description,'(interior)']);
    cost_interior = setParSymbols(cost_interior,{'nNode'});
    obj.Funcs.Phase{phase_idx}.([func.Name,'_interior']) = cost_interior;
    
    
    % nlp function for terminal nodes
    cost{1} = {NlpFunction('Name',cost_terminal.Name,...
        'Dimension',1, 'Type', 'nonlinear','DepVariables',...
        {horzcat({var_table{'T',1}{1}},...
        cellfun(@(x)var_table{x,1}{1},func.DepSymbols,'UniformOutput',false))},...
        'AuxData', n_node,...
        'Funcs', obj.Funcs.Phase{phase_idx}.([func.Name,'_terminal']).Funcs)};
        
    if obj.Options.DistributeParamWeights
        node_time = n_node;
    else
        node_time = 1;
    end
    cost{n_node} = {NlpFunction('Name',cost_terminal.Name,...
        'Dimension',1, 'Type', 'nonlinear','DepVariables',...
        {horzcat({var_table{'T',node_time}{1}},...
        cellfun(@(x)var_table{x,n_node}{1},func.DepSymbols,'UniformOutput',false))},...
        'AuxData', n_node,...
        'Funcs', obj.Funcs.Phase{phase_idx}.([func.Name,'_terminal']).Funcs)};
    
    % nlp function for interior nodes
    for i=2:n_node-1
        if obj.Options.DistributeParamWeights
            node_time = i;
        else
            node_time = 1;
        end
        cost{i} = {NlpFunction('Name',cost_interior.Name,...
            'Dimension',1, 'Type', 'nonlinear','DepVariables',...
            {horzcat({var_table{'T',node_time}{1}},...
            cellfun(@(x)var_table{x,i}{1},func.DepSymbols,'UniformOutput',false))},...
            'AuxData', n_node,...
            'Funcs', obj.Funcs.Phase{phase_idx}.([func.Name,'_interior']).Funcs)};
    end
    
    % add to cost table
    obj.Phase{phase_idx}.CostTable = [...
        obj.Phase{phase_idx}.CostTable;...
        cell2table(cost,'RowNames',{func.Name},'VariableNames',col_names)];
end