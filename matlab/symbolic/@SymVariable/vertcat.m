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
    
    
    % Call the superclass method
    str = vertcat@SymExpression(varargin{:});
    
    % create a new object with the evaluated string
    y = SymVariable(str);
    
    

end