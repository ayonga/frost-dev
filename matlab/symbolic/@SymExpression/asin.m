function Y = asin(X)
    % Symbolic inverse sine.


    % Convert inputs to SymExpression
    X = SymExpression(X);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['ArcSin[' X.s ']']);
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
