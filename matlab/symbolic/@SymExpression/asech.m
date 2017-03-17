function Y = asech(X)
    % Symbolic inverse hyperbolic secant.

    % Convert inputs to SymExpression
    X = SymExpression(X);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['ArcSech[' X.s ']']);
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
