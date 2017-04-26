function Y = acosh(X)
    %ACOSH  Symbolic inverse hyperbolic cosine.
    
    
    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['ArcCosh[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
