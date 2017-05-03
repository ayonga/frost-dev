function obj = removeCost(obj, label)
    % Removes a group of NLP cost functions 
    %
    % Parameters:
    % label: the label name (column) of the cost function @type char
    %
    % @see addCost
    
    
    assert(~isempty(str_index(label,obj.CostTable.Properties.VariableNames)),...
        'Cannot delete ''%s'' from the table because it does not exist.\n',label);
    
    % warning('Removing the cost (%s) from the cost table.\n',label);
    obj.CostTable.(label) = [];
    
    
end