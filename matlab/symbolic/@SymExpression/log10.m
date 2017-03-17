function Y = log10(X)
    % Symbolic matrix element-wise common logarithm.


    % Convert inputs to SymExpression
    X = SymExpression(X);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['Log[' X.s ',10]']);
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
