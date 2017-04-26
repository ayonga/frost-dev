function Y = acsc(X)
    % Symbolic inverse cosecant.

    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['ArcCsc[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
