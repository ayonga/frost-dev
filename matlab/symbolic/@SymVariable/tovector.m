function B = tovector(A)
    % Flatten the symbolic expression

    
    % Convert inputs to SymExpression
    A = tovector@SymExpression(A);
    
    
    % create a new object with the evaluated string
    B = SymVariable(A);

end