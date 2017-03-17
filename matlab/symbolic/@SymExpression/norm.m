function c = norm(A,p)
    % norm   Norm of a symbolic matrix or vector
    %
    %  For a symbolic matrix A
    %      norm(A) returns the 2-norm of A. This is the same result as
    %              returned by norm(A,2).
    %      norm(A,1) returns the 1-norm of A.
    %      norm(A,2) returns the 2-norm of A.
    %      norm(A,Inf) returns the Infinity norm of A.
    %      norm(A,'fro') returns the Frobenius norm of A.
    %
    %  For a symbolic vector v
    %      norm(v,p) returns the p-norm of the vector v. Here p can be
    %                any number.
    %      norm(v,Inf) returns the largest element of abs(v).
    %      norm(v,-Inf) returns the smallest element of abs(v).
    %
    %   Examples:
    %      syms x y z a b c d;
    %      A = [a b; c d];
    %      v = [a; b; c];
    %
    %      norm(A)
    %      norm(A,1)
    %      norm(A,Inf)
    %      norm(A,'fro')
    %
    %      norm(v,2)
    %      norm(v,Inf)
    %      norm(v,-Inf)
    %
    %   See also cond, inv, norm, rank.
  
    % Convert inputs to SymExpression
    A = SymExpression(A);
    
    if nargin < 2
        p = 2;
    end


    if ischar(p)
        try
            p = validatestring(p, {'fro','inf'});
        catch err
            error(message('symbolic:sym:norm:InvalidMatrixNorm'));
        end
    elseif isnumeric(p)
        if ~isscalar(p)
            error(message('symbolic:sym:norm:InvalidMatrixNorm'));
        end
    end
    
    
    if isempty(A)
        c = SymExpression(0);
    elseif isnumeric(p) && p~=inf
        sstr = eval_math(['Norm[' A.s ',' num2str(p) ']']);
        c = SymExpression(sstr);
    elseif ischar(p) && strcmp(p,'fro')
        sstr = eval_math(['Norm[' A.s ',"Frobenius"]']);
        c = SymExpression(sstr);
    elseif (ischar(p) && strcmp(p,'inf')) || p == inf
        sstr = eval_math(['Norm[' A.s ',Infinity]']);
        c = SymExpression(sstr);
    else
        error(message('symbolic:sym:norm:InvalidMatrixNorm'));
    end
    
end
