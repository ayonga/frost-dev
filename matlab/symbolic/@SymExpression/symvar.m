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

    % return the input object if it is a SymVariable object
    %     if isa(S,'SymVariable')
    %         y = S;
    %         return;
    %     end
    
    % return the variables if it is a SymFunction
    %     if isa(S,'SymFunction')
    %         y = S.vars;
    %         return;
    %     end
    
    % Convert inputs to SymExpression
    S = SymExpression(S);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    svars = eval_math(['FindSymbols[ToMatrixForm[' S.s ']]']);
    
    % convert symbolic variables (expression) to strings
    str = eval(math(['("''" <> ToString[#] <> "''") & /@ ', svars]));
    
    
    % create a new object with the evaluated string
    y_c = cellfun(@SymVariable,str,'UniformOutput',false);
    
    y = [y_c{:}];
end
