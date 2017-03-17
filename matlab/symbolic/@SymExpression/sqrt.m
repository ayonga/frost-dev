function Y = sqrt(X)
    % Symbolic matrix element-wise square root.

    % Convert inputs to SymExpression
    X = SymExpression(X);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['Sqrt[' X.s ']']);
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
