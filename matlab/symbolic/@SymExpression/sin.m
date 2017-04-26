function Y = sin(X)
    % Symbolic sine function.
       
    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Sin[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
