function Y = csch(X)
    % Symbolic hyperbolic cosecant.

    % Convert inputs to SymExpression
    X = SymExpression(X);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['Csch[' X.s ']']);
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);
end
