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
    
    phase_idx = getPhaseIndex(obj, phase);
    phase_info = obj.Phase{phase_idx};


    n_node = phase_info.NumNode;
    col_names = phase_info.OptVarTable.Properties.VariableNames;
    
    
    if obj.Options.DistributeParamWeights
        % state variables are defined at all cardinal nodes if
        % distributes the weightes
        node_list = 1:1:n_node;
    else
        % otherwise only define at the first node
        node_list = 1;
    end
    
    
    % create a cell array of time NlpVariable objects
    t = repmat({{}},1, n_node);
    for i=node_list
        t{i} = {NlpVariable('Name', 't', 'Dimension', 1, ...
            'lb', lb, 'ub', ub, 'x0', x0)};
    end
    
    
    obj.Phase{phase_idx}.OptVarTable = [...
        obj.Phase{phase_idx}.OptVarTable;...
        cell2table(t,'VariableNames',col_names,'RowNames',{'T'})];


end