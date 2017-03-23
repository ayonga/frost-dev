function y = vertcat(varargin)
    % Vertical concatenation for sym arrays.
    %   C = VERTCAT(A, B, ...) vertically concatenates the sym arrays A,
    %   B, ... .  For matrices, all inputs must have the same number of columns.
    %   For N-D arrays, all inputs must have the same sizes except in the first
    %   dimension.
    %
    %   C = VERTCAT(A,B) is called for the syntax [A; B].
    %
    %   See also HORZCAT.
    
    
    X = cellfun(@(x)SymVariable(x),varargin,'UniformOutput',false);
        %     X = SymExpression(varargin);
    str = cellfun(@(x)eval_math(['ToMatrixForm@',x.s]),X,'UniformOutput',false);
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['Join[' implode(str, ', ') ']']);
    
    % create a new object with the evaluated string
    y = SymVariable(SymExpression(sstr));
    
    

end