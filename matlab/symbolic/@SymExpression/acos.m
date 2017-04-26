function Y = acos(X)
    % Symbolic inverse cosine.


    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['ArcCos[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end