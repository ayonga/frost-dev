function obj = addConstraint(obj, label, nodes, cstr_array)
    % Add NLP constraints constraints
    %
    %
    % Parameters:
    % label: the label name (column) of the constraints @type char
    % nodes: the node list of the variable @type rowvec
    % cstr_array: an array of structures that could be used to construct
    % the NlpFunction object. @type struct
    % 
    % @see NlpFunction, removeConstraint
    %
    % @note 
    
    
    
    
    cstr_names = obj.ConstrTable.Properties.VariableNames;
    
%     if ismember(label,cstr_names)
%         warning('The NLP constraint (%s) already exist.\n Overwriting the existing constraint.', label);
%     end
    
    if ischar(nodes)
        switch nodes
            case 'first'
                node_list = 1;
            case 'last'
                node_list = obj.NumNode;
            case 'terminal'
                node_list = [1 obj.NumNode];
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
    
    
    assert(length(node_list)==length(cstr_array),...
        'The length of the array (%d) of constraint structures must be the same as the number of nodes (%d) to be imposed.',...
        length(cstr_array),length(node_list));
    
    % create empty NlpVariable array
    if isa(cstr_array,'NlpFunction')
        constr = repmat(NlpFunction(),obj.NumNode,1);
        for j=1:numel(node_list)
            constr(node_list(j)) = cstr_array(j);
        end
    elseif isstruct(cstr_array)
        
        constr = repmat(NlpFunction(),obj.NumNode,1);
        for j=1:numel(node_list)
            constr(node_list(j)) = NlpFunction(cstr_array(j));
        end
    end
    
    % add to the constraints table
    if ismember(label,cstr_names)
        obj.ConstrTable.(label)(node_list) = constr(node_list);
    else
        obj.ConstrTable.(label) = constr;
    end
end