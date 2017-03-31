function obj = addTerminalCost(obj, phase, name, func, deps, nodes, auxdata)
    % Add a terminal cost to the problem
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    % name: the name of the function @type char
    % func: a symbolic function to be integrated @type struct
    % deps: a list of dependent variables @type cellstr
    % nodes: indicates at which nodes (first or last) be defined @type double
    % auxdata: (optional) auxilary arguments
    
    
    
    if nargin < 6
        auxdata = [];
    end
    
    phase_idx = getPhaseIndex(obj, phase);
    phase_info = obj.Phase{phase_idx};


    n_node = phase_info.NumNode;
    col_names = phase_info.CostTable.Properties.VariableNames;
    var_table= phase_info.OptVarTable;
    cost  = repmat({{}},1, n_node);
    
    % nlp function for interior nodes
    for i=nodes
        cost{i} = {NlpFunction('Name',name,...
            'Dimension',1, 'Type', 'nonlinear','DepVariables',...
            {cellfun(@(x)var_table{x,i}{1},deps,'UniformOutput',false)},...
            'AuxData', auxdata,...
            'Funcs', func)};
    end
    
    
    
    
    
    
    
    % add to cost table
    obj.Phase{phase_idx}.CostTable = [...
        obj.Phase{phase_idx}.CostTable;...
        cell2table(cost,'RowNames',{name},'VariableNames',col_names)];
end