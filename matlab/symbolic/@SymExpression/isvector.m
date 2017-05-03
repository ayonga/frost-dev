function y = isvector(X)
    % True if X is a 1-Dimensional list 
    
    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    siz = size(X);
    if numel(siz) == 1
        y = true;
    elseif numel(siz)==2 && (siz(1)==1 || siz(2)==1)
        y = true;
    else
        y = false;
    end
end
