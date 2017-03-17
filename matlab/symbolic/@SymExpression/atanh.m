function Y = atanh(X)
    % Symbolic inverse hyperbolic tangent.

    % Convert inputs to SymExpression
    X = SymExpression(X);
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['ArcTanh[' X.s ']']);
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
