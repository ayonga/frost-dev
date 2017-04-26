function Y = exp(X)
    % Symbolic matrix element-wise exponentiation.
    
    
    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Exp[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
