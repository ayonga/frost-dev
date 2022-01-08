function y = isempty(X)
    % True if X is a scalar symbolic expression
    
    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    y = builtin('isempty',X);
    if y
        return;
    end
    
    siz = dimension(X);
    
    if prod(siz) == 0
        y = true;
    else
        y = false;
    end
end