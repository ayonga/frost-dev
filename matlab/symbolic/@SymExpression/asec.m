function Y = asec(X)
    % Symbolic inverse secant.

    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['ArcSec[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
    
end
