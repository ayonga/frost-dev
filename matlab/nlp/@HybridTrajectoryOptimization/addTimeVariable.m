function obj = addTimeVariable(obj, phase, lb, ub, x0)
    % Adds time as the NLP decision variables to the problem
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    % lb: the lower bound of the phase time @type double
    % ub: the upper bound of the phase time @type double
    % x0: the typical initial value of the phase time @type double
    
    if (nargin < 3) 
        lb = 0; 
    end
    if (nargin < 4) 
        ub = 1; 
    end
    if (nargin < 5) 
        x0 = 0.5; 
    end
    
    num_node = obj.Phase{phase}.NumNode;
    col_names = obj.Phase{phase}.OptVarTable.Properties.VariableNames;
    
    
    if obj.Options.DistributeParamWeights
        % state variables are defined at all cardinal nodes if
        % distributes the weightes
        switch obj.Options.CollocationScheme
            case 'HermiteSimpson'
                nodeList = 1:2:num_node;
            case 'Trapzoidal'
                nodeList = 1:1:num_node;
            case 'PseudoSpectral'
                nodeList = 1:1:num_node;
        end
    else
        % otherwise only define at the first node
        nodeList = 1;
    end
    
    
    % create a cell array of time NlpVariable objects
    t = cell(1, num_node);
    for i=nodeList
        t{i} = NlpVariable('Name', 't', 'Dimension', 1, ...
            'lb', lb, 'ub', ub, 'x0', x0);
    end
    
    
    obj.Phase{phase}.OptVarTable = [...
        obj.Phase{phase}.OptVarTable;...
        cell2table(t,'VariableNames',col_names,'RowNames',{'t'})];


end