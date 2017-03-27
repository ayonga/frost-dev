function y = isvector(X)
    % True if X is a 1-Dimensional list 
    
    % Convert inputs to SymExpression
    X = SymExpression(X);
    
    [m, n] = size(X);
    
    if m==1 || n==1
        y = true;
    else
        y = false;
    end
end
