function B = nzind(A, level)
    % The indices of non-zero entries of the symbolic expression A.
    
    
    if nargin == 1
        if ismatrix(A)
            level = 2;
        elseif isvector(A)
            level = 1;
        else
            level = 1;
        end
    end
    
    assert(isreal(level) && isscalar(level) && (rem(level,1)==0 || isinf(level)),...
        'The level specification must be a scalar integer.');
    
    
    % Convert inputs to SymExpression
    A = SymExpression(A);
    
    % construct the operation string
    sstr = ['Position[' A.s ', Except[0], {' num2str(level) '}, Heads -> False]'];
    
    % create a new object with the evaluated string
    B = SymExpression(sstr);

end