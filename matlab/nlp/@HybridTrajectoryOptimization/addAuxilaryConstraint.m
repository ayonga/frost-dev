function obj = addAuxilaryConstraint(obj, phase, nodes, deps, varargin)
    % Add auxilary user-defined constraints constraints
    %
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    % nodes: the node list of the variable @type rowvec
    % deps: a cell array dependent variables @type cell
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
    for i=nodes
        constr{i} = {NlpFcnction(...
            varargin{:},'DepVariables',{deps{i}})};
    end
    
    obj.Phase{phase_idx}.ConstrTable = [...
        obj.Phase{phase_idx}.ConstrTable;...
        cell2table(constr,'RowNames',{constr{nodes(1)}{1}.Name},'VariableNames',col_names)];
end