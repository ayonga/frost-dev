function B = flatten(A)
    % Flatten the symbolic expression

    
    % Convert inputs to SymExpression
    A = flatten@SymExpression(A);
    
    
    % create a new object with the evaluated string
    B = SymVariable(A);

end