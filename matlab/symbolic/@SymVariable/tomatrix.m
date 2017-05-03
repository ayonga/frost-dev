function B = tomatrix(A)
    % Flatten the symbolic expression

    
    % Convert inputs to SymExpression
    A = tomatrix@SymExpression(A);
    
    
    % create a new object with the evaluated string
    B = SymVariable(A);


end