function Y = tanh(X)
    % Symbolic hyperbolic tangent.
    
    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Tanh[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
