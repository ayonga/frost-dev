function Y = sqrt(X)
    % Symbolic matrix element-wise square root.

    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Sqrt[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
