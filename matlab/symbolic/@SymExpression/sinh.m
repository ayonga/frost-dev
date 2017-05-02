function Y = sinh(X)
    % Symbolic hyperbolic sine.
    
    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Sinh[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
