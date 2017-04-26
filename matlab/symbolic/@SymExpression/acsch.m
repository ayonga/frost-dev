function Y = acsch(X)
    % Symbolic inverse hyperbolic cosecant.


    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['ArcCsch[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
