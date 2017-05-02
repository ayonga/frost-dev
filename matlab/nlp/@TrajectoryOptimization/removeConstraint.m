function obj = removeConstraint(obj, label)
    % Removes a group of NLP constraints 
    %
    % Parameters:
    % label: the label name (column) of the constraints @type char
    %
    % @see addConstraint
    
    
    assert(~isempty(str_index(label,obj.ConstrTable.Properties.VariableNames)),...
        'Cannot delete ''%s'' from the table because it does not exist.\n',label);
    
    % warning('Removing the constraint (%s) from the constraist table.\n',label);
    obj.ConstrTable.(label) = [];
    
    
end