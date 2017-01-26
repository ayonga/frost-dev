function obj = addAuxilaryVariable(obj, phase, nodes, varargin)
    % Adds auxilary defect variables (such as h or impF) as the NLP
    % decision variables to the problem
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    % nodes: the node list of the variable @type rowvec
    % varargin: variable input arguments for property values non-empty
    % NlpVariables @copydoc NlpVariable.updateProp
    % 
    % @see NlpVariable
    
    
    
    
    
    phase_idx = getPhaseIndex(obj, phase);
    phase_info = obj.Phase{phase_idx};


    n_node = phase_info.NumNode;
    col_names = phase_info.OptVarTable.Properties.VariableNames;
    
    
    
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