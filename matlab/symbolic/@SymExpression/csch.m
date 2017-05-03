function Y = csch(X)
    % Symbolic hyperbolic cosecant.

    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Csch[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
