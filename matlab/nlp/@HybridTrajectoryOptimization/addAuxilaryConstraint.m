function obj = addAuxilaryConstraint(obj, phase, nodes, varargin)
    % Add auxilary user-defined constraints constraints
    %
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    % nodes: the node list of the variable @type rowvec
    % varargin: variable input arguments for property values non-empty
    % NlpFunction other than the DepVariables
    % 
    % @see NlpFunction
    %
    % @note The deps must have the same length as the nodes.
    
    
    % extract phase information
    phase_idx = getPhaseIndex(obj, phase);
    phase_info = obj.Phase{phase_idx};
    
    % local variable for fast access
    n_node = phase_info.NumNode;
    col_names = phase_info.ConstrTable.Properties.VariableNames;
    
    
    
    constr = repmat({{}},1, n_node);
    
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
    
    for i=nodes
        constr{i} = {NlpFcnction(...
            varargin{:},'DepVariables',{deps{i}})};
    end
    
    obj.Phase{phase_idx}.ConstrTable = [...
        obj.Phase{phase_idx}.ConstrTable;...
        cell2table(constr,'RowNames',{constr{nodes(1)}{1}.Name},'VariableNames',col_names)];
end