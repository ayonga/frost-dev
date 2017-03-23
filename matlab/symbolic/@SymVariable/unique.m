function y = unique(A) 
    %  Symbolic unique function.
    
    
    if ~isa(A, 'SymVariable')
        error('Invalid input. Expected SymExpression objects.');
    end
    
    if isscalar(A)
        y = A;
        return;
    end
    % evaluate the operation in Mathematica and return the
    % expression string
    svars = eval_math(['DeleteDuplicates[Flatten[' A.s ']]']);
    
    % convert symbolic variables (expression) to strings
    str = eval(math(['("''" <> ToString[#] <> "''") & /@ ', svars]));
    
    
    % create a new object with the evaluated string
    y_c = cellfun(@SymVariable,str,'UniformOutput',false);
    
    
    y = [y_c{:}];
end