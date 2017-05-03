function Y = atanh(X)
    % Symbolic inverse hyperbolic tangent.

    % Convert inputs to SymExpression
    % X = SymExpression(X);
    % construct the operation string
    sstr = ['ArcTanh[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
