function B = flatten(A)
    % Flatten the symbolic expression

    
    % Convert inputs to SymExpression
    A = SymExpression(A);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['ToVectorForm[' A.s ']']);
    
    % create a new object with the evaluated string
    B = SymExpression(sstr);

end