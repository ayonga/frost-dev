function obj = addCost(obj, label, nodes, cost_array)
    % Add NLP object functions
    %
    %
    % Parameters:
    % label: the label name (column) of the cost @type char
    % nodes: the node list of the variable @type rowvec
    % cost_array: an array of structures that could be used to construct
    % the NlpFunction object. @type struct
    % 
    % @see NlpFunction, removeCost
    %
    % @note 
    
    
    
    
    cstr_names = obj.CostTable.Properties.VariableNames;
    
%     if ismember(label,cstr_names)
%         warning('The NLP cost functions (%s) already exist.\n Overwriting the existing cost function.', label);
%     end
    
    
    if ischar(nodes)
        switch nodes
            case 'first'
                node_list = 1;
            case 'last'
                node_list = obj.NumNode;
            case 'except-first'
                node_list = 2:obj.NumNode;
            case 'except-last'
                node_list = 1:obj.NumNode-1;
            case 'except-terminal'
                node_list = 2:obj.NumNode-1;
            case 'all'
                node_list = 1:obj.NumNode;
            case 'cardinal'
                node_list = 1:2:obj.NumNode;
            case 'interior'
                node_list = 2:2:obj.NumNode-1;
            otherwise
                error('Unknown node type.');
        end
    else
        if ~isnumeric(nodes)
            error(['The node must be specified as a list or following supported characters:\n',...
                '%s'],implode({'first','last','all','except-first','except-last','except-terminal', 'cardinal', 'interior'},','));
        else
            node_list = nodes;
        end
    end
    
    
    assert(length(node_list)==length(cost_array),...
        'The length of the array (%d) of constraint structures must be the same as the number of nodes (%d) to be imposed.',...
        length(cost_array),length(node_list));
    
    % create empty NlpVariable array
    if isa(cost_array,'NlpFunction')
        costs = repmat(NlpFunction(),obj.NumNode,1);
        for j=1:numel(node_list)
            costs(node_list(j)) = cost_array(j);
        end
    elseif isstruct(cost_array)
        
        costs = repmat(NlpFunction(),obj.NumNode,1);
        for j=1:numel(node_list)
            costs(node_list(j)) = NlpFunction(cost_array(j));
        end
    end
    
    % add to the cost function table
    if ismember(label,cstr_names)
        obj.CostTable.(label)(node_list) = costs(node_list);
    else
        obj.CostTable.(label) = costs;
    end
end