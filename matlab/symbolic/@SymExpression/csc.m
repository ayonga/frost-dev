function Y = csc(X)
    % Symbolic cosecant.

    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Csc[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
