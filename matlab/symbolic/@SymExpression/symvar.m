function y = symvar(S)
    %SYMVAR Finds the symbolic variables in a symbolic expression or matrix.
    %    SYMVAR(S), where S is a scalar or matrix sym, returns a vector sym
    %    containing all of the symbolic variables appearing in S. The
    %    variables are returned in lexicographical order. If no symbolic variables
    %    are found, SYMVAR returns the empty vector.
    %    The constants pi, i and j are not considered variables.
    %
    %    Examples:
    %       symvar(alpha+a+b) returns
    %        [a, alpha, b]
    %    
    %       symvar(y*(4+3*i) + 6*j) returns
    %        y


    % Convert inputs to SymExpression
    S = SymExpression(S);
    
    str = eval_math(['ToMatrixForm@' S.s ]);
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['FindSymbols[' str ']']);
    
    % create a new object with the evaluated string
    y = SymExpression(sstr);
end
