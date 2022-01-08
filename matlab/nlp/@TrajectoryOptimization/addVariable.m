function obj = addVariable(obj, nodes, varargin)
    % Adds NLP decision variables 
    %
    % Parameters:
    % nodes: the node list of the variable @type rowvec
    % varargin: variable input arguments for property values non-empty
    % NlpVariables @copydoc NlpVariable::updateProp
    % 
    % @see NlpVariable, removeVariable
    
    if isa(varargin{1}, 'BoundedVariable')
        var_obj = varargin{1};
        label = var_obj.Name;
        var_props = struct(varargin{2:end});
    else
        var_obj = [];
        var_props = struct(varargin{:});        
        label = var_props.Name;
    end
    
    
    %     varnames = obj.OptVarTable.Properties.VariableNames;

    %     if ismember(label,varnames)
    %         warning('The NLP variable (%s) already exists.\n Overwriting the existing NLP variable.', label);
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
            error(['The node must be specified as a list of node indices or following supported characters:\n',...
                '%s'],implode({'first','last','all','except-first','except-last','except-terminal', 'cardinal', 'interior'},','));
        else
            node_list = nodes;
            assert(max(nodes) <= obj.NumNode, 'The maximum value of the node exceeds the number of nodes available.');
        end
    end
    
    % create empty NlpVariable array
    vars = repmat(NlpVariable(),obj.NumNode,1);
    
    var_props = namedargs2cell(var_props);
    for i=node_list
        if isempty(var_obj)
            vars(i) = NlpVariable(var_props{:});
        else
            vars(i) = NlpVariable(var_obj, var_props{:});            
        end
    end
    % add to the decision variable table
    obj.OptVarTable.(label) = vars;
    


end