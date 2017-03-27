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
    
    
    X = cellfun(@(x)SymExpression(x),varargin,'UniformOutput',false);
        %     X = SymExpression(varargin);
    str = cellfun(@(x)x.s,X,'UniformOutput',false);
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = ['Join[Sequence@@ToMatrixForm/@' cell2tensor(str,'ConvertString',false) ']'];
    
    % create a new object with the evaluated string
    y = SymExpression(sstr);

end