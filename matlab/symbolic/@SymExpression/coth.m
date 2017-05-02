function Y = coth(X)
    % Symbolic hyperbolic cotangent.

    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Coth[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
