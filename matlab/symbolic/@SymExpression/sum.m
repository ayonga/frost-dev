function s = sum(A,p)
    %  Sum of the elements.
    %   For vectors, SUM(X) is the sum of the elements of X.
    %   For matrices, SUM(X) or SUM(X,1) is a row vector of column sums
    %   and SUM(X,2) is a column vector of row sums and SUM(X,Inf) is total
    %   sums of all elements of X.
    %
    %   See also SYM/PROD.
    
    
    if nargin < 2
        p = 1;
    end
    
    % Convert inputs to SymExpression
    % A = SymExpression(A);
    
    % construct the operation string
    if p == 1
        sstr = ['Total[' A.s ']'];
    elseif p == 2
        sstr = ['Total[' A.s ',{2}]'];
    elseif p == inf
        sstr = ['Total[' A.s ',Infinity]'];
    else
        error('p must be one of the following: 1, 2, inf');
    end
    % create a new object with the evaluated string
    s = SymExpression(sstr);
    
end


