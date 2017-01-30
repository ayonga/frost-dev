function obj = addAuxilaryVariable(obj, phase, nodes, varargin)
    % Adds auxilary defect variables (such as h or impF) as the NLP
    % decision variables to the problem
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    % nodes: the node list of the variable @type rowvec
    % varargin: variable input arguments for property values non-empty
    % NlpVariables @copydoc NlpVariable::updateProp
    % 
    % @see NlpVariable
    
    
    
    
    
    phase_idx = getPhaseIndex(obj, phase);
    phase_info = obj.Phase{phase_idx};


    n_node = phase_info.NumNode;
    col_names = phase_info.OptVarTable.Properties.VariableNames;
    
    if ischar(nodes)
        switch nodes
            case 'first'
                nodes = 1;
            case 'last'
                nodes = n_node;
            case 'all'
                nodes = 1:nodes;
            case 'cardinal'
                nodes = 1:2:n_node;
            case 'interior'
                nodes = 2:2:n_node-1;
        end
    else
        if ~isnumeric(nodes)
            error(['The node must be specified as a list or following supported characters:\n',...
                '%s'],implode({'first','last','all','cardinal','interior'},','));
        end
    end
    
    var = repmat({{}},1, n_node);
    for i=nodes
        var{i} = {NlpVariable(...
            varargin{:})};
    end
    % add to the decision variable table
    obj.Phase{phase_idx}.OptVarTable = [...
        obj.Phase{phase_idx}.OptVarTable;...
        cell2table(var,'VariableNames',col_names,'RowNames',{var{nodes(1)}{1}.Name})];
    


end