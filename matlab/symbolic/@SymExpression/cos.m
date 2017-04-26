function Y = cos(X)
    % Symbolic cosine function.

    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Cos[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
