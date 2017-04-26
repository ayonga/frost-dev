function Y = cosh(X)
    % Symbolic hyperbolic cosine.
    
    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Cosh[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
