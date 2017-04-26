function Y = sec(X)
    % Symbolic secant.


    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Sec[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
