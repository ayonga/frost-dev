function Y = log(X)
    %  Symbolic matrix element-wise natural logarithm.


    % Convert inputs to SymExpression
    % X = SymExpression(X);
    
    % construct the operation string
    sstr = ['Log[' X.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
