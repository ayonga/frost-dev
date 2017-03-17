function Y = coth(X)
    % Symbolic hyperbolic cotangent.

    % Convert inputs to SymExpression
    X = SymExpression(X);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['Coth[' X.s ']']);
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
