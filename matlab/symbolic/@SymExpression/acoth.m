function Y = acoth(X)
    % Symbolic inverse hyperbolic cotangent.

    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['ArcCoth[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
