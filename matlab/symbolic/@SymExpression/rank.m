function r = rank(A)
    % Symbolic matrix rank.
    %   RANK(A) is the rank of the symbolic matrix A.
    %
    %   Example:
    %       rank([a b;c d]) is 2.


    % Convert inputs to SymExpression
    % A = SymExpression(A);
    
    % evaluate the operation in Mathematica and return the
    % expression string
    r = eval_math(['{{MatrixRank[' A.s ']}}'],'math2matlab');
    
end
