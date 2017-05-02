function Y = asinh(X)
    % Symbolic inverse hyperbolic sine.

    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['ArcSinh[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
