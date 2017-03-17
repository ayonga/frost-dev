function y = horzcat(varargin)
    %HORZCAT Horizontal concatenation for sym arrays.
    %   C = HORZCAT(A, B, ...) horizontally concatenates the sym arrays A,
    %   B, ... .  For matrices, all inputs must have the same number of rows.  For
    %   N-D arrays, all inputs must have the same sizes except in the second
    %   dimension.
    %
    %   C = HORZCAT(A,B) is called for the syntax [A B].
    %
    %   See also VERTCAT.
    
    X = cellfun(@(x)SymExpression(x),varargin,'UniformOutput',false);
        %     X = SymExpression(varargin);
    str = cellfun(@(x)eval_math(['ToMatrixForm@',x.s]),X,'UniformOutput',false);
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['Join[' implode(str, ', ') ',2]']);
    
    % create a new object with the evaluated string
    y = SymExpression(sstr);

end