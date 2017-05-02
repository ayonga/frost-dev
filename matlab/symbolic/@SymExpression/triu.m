function Y = triu(X,offset)
    % Symbolic upper triangle.
    %   TRIU(X) is the upper triangular part of X.
    %   TRIU(X,K) is the elements on and above the K-th diagonal of
    %   X.  K = 0 is the main diagonal, K > 0 is above the main
    %   diagonal and K < 0 is below the main diagonal.
    %
    %   Examples:
    %
    %      Suppose
    %         A =
    %            [   a,   b,   c ]
    %            [   1,   2,   3 ]
    %            [ a+1, b+2, c+3 ]
    %
    %      then
    %         triu(A) returns
    %            [   a,   b,   c ]
    %            [   0,   2,   3 ]
    %            [   0,   0, c+3 ]
    %
    %         triu(A,1) returns
    %            [ 0, b, c ]
    %            [ 0, 0, 3 ]
    %            [ 0, 0, 0 ]
    %
    %         triu(A,-1) returns
    %            [   a,   b,   c ]
    %            [   1,   2,   3 ]
    %            [   0, b+2, c+3 ]
    %
    %   See also SYM/TRIL.
    
    if nargin == 1
        offset = 0;
    end
    
    % Convert inputs to SymExpression
    X = SymExpression(X);
    offset = SymExpression(offset);
    
    
    % construct the operation string
    sstr = ['UpperTriangularize[' X.s ',' offset.s ']'];
    
    % create a new object with the evaluated string
    Y = SymExpression(sstr);

end