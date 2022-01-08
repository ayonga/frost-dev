function obj = addNodeCost(obj, nodes, func, deps, auxdata)
    % Add a cost function that only depends on variables at a particular
    % node. The input argument ''nodes'' will specify at which nodes the
    % function is defined. 
    %
    % @note This function provides a simple type of cost function which
    % dependends only on variables at some particular node. If multiple
    % nodes are specified, the final cost function will be the sum of the
    % function computated at each node.
    %
    % @attention In the case the cost function dependes on variables at
    % different nodes, please use the basic ''addCost'' method directly.
    %
    % @attention This method can be used to add any terminal cost function
    % by specify ''nodes'' as either ''first'' or ''last''.
    %
    % Parameters:
    % func: a symbolic function to be integrated @type SymFunction
    % deps: a list of dependent variables @type cellstr
    % node: an indicator of 'first' or 'last' node @type char
    % auxdata: auxilary constant data to be feed in the function 
    % @type double
    arguments
        obj        
        nodes
        func
        deps (:,1) cell
        auxdata cell = {}
    end
    
    % basic information of NLP decision variables
    
    vars   = obj.OptVarTable;
    
    
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
    elseif isnumeric(nodes)
        mustBeInteger(nodes);
        mustBeInRange(nodes,1,obj.NumNode);
        node_list = nodes;
    else
        error(['The node must be specified as a list of integers or following supported characters:\n',...
            '%s'],implode({'first','last','all','except-first','except-last','except-terminal', 'cardinal', 'interior'},','));
    end
    
      
    n_node = numel(node_list);
    cost = repmat(NlpFunction(),n_node,1);
    for i=1:n_node
        idx = node_list(i);
        dep_vars = cellfun(@(x)get_dep_vars(obj.Plant, vars, obj.Options, x, idx),deps,'UniformOutput',false);        
        cost(i) = NlpFunction(func, [dep_vars{:}], 'AuxData', auxdata);
    end
    
    
    obj = addCost(obj,nodes,cost);
    
    function var = get_dep_vars(plant, vars, options, x, idx)
        
        if strcmp(x,'T') && ~options.DistributeTimeVariable % time variable
            var = vars.(x)(1);
        elseif isParam(plant, x) && ~options.DistributeParameters
            var = vars.(x)(1);
        else
            var = vars.(x)(idx);
        end
        
    end
end