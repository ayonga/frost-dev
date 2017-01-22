function obj = addAuxilaryVariable(obj, phase, nodes, varargin)
    % Adds auxilary defect variables (such as h or impF) as the NLP
    % decision variables to the problem
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    % nodelist: the node list of the variable @type rowvec
    % varargin: variable input arguments for property values non-empty
    % NlpVariables @copydoc NlpVariable.updateProp
    % 
    % @see NlpVariable
    
    
    
    
    
    num_node = obj.Phase{phase}.NumNode;
    col_names = obj.Phase{phase}.OptVarTable.Properties.VariableNames;
    
    
    
    
    var = create_object_array('NlpVariable', num_node, nodes, ...
        varargin{:});
    
    % add to the decision variable table
    obj.Phase{phase}.OptVarTable = [...
        obj.Phase{phase}.OptVarTable;...
        array2table(var,'VariableNames',col_names,'RowNames',{var(nodes(1)).Name})];
    


end