function Y = tan(X)
    % Symbolic tangent function.
    
    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Tan[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
