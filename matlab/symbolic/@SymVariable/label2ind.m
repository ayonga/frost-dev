function indices = label2ind(obj, labels)
    % Returns the indices of SymVariable specified by the label string
    %
    % Parameters:
    %  labels: a cellstr array of the labels
    %
    % Return values:
    %  indices: position indices of symbolic variable 
    % 
    
    
    
    if ~iscell(labels), labels = {labels}; end
    
    
    nj = numel(labels);
    
    indices = zeros(nj,1);
    
    for i=1:nj
        index = str_index(obj.label,labels{i});
        if isempty(index)
            error('the label %s not found.', labels{i});
        else
            indices(i) = index;
        end
        
    end
    
   
    
    
end
