function Y = cot(X)
    % Symbolic cotangent.

    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Cot[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
