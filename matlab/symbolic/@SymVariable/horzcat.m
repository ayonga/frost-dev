function y = horzcat(varargin)
    % Horizontal concatenation for sym arrays.
    %   C = HORZCAT(A, B, ...) horizontally concatenates the symbolic
    %   variable arrays A, B, ... .  For matrices, all inputs must have the
    %   same number of rows.  
    %
    %   C = HORZCAT(A,B) is called for the syntax [A B].
    %
    %   See also VERTCAT.
    
    % Call the superclass method
    str = horzcat@SymExpression(varargin{:});
    
    % create a new object with the evaluated string
    y = SymVariable(str);

end