function Y = acot(X)
    % Symbolic inverse cotangent.


    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['ArcCot[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
