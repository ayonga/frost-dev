function Y = asech(X)
    % Symbolic inverse hyperbolic secant.

    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['ArcSech[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
