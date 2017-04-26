function B = tomatrix(A)
    % Flatten the symbolic expression

    
    % Convert inputs to SymExpression
    % A = SymExpression(A);
    
    % construct the operation string
    sstr = ['ToMatrixForm[' A.s ']'];
    
    % create a new object with the evaluated string
    B = SymExpression(sstr);

end