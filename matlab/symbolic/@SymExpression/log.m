function Y = log(X)
    %  Symbolic matrix element-wise natural logarithm.


    % Convert inputs to SymExpression
    X = SymExpression(X);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['Log[' X.s ']']);
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
