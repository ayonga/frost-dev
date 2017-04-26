function Y = log2(X)
    % Symbolic matrix element-wise base-2 logarithm.


    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Log[' X.s ',2]'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
