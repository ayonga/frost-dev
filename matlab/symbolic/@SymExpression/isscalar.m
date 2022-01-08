function y = isscalar(X)
    % True if X is a scalar symbolic expression
    
    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    siz = dimension(X);
    
    if prod(siz) == 1
        y = true;
    else
        y = false;
    end
end
