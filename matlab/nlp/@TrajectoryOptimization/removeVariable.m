function obj = removeVariable(obj, label)
    % Removes a NLP optimization variable 
    %
    % Parameters:
    % label: the label name (column) of the variable @type char
    %
    % @see addVariable
    
    
    
    %     assert(~isempty(str_index(label,obj.OptVarTable.Properties.VariableNames)),...
    %         'Cannot delete ''%s'' from the table because it does not exist.\n',label);
    
    % warning('Removing the variable (%s) from the optimization variable table.\n',label);
    if ~isempty(str_index(label,obj.OptVarTable.Properties.VariableNames))
        obj.OptVarTable.(label) = [];
    else
        warning('Cannot delete ''%s'' from the table because it does not exist.\n',label);
    end
    
    
end