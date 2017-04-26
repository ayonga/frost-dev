function B = flatten(A)
    % Flatten the symbolic expression

    
    % Convert inputs to SymExpression
    % A = SymExpression(A);
    
    % construct the operation string
    sstr = ['{ToVectorForm[' A.s ']}'];
    
    % create a new object with the evaluated string
    B = SymExpression(sstr);

end