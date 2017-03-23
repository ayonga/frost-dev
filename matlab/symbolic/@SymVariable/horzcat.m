function y = horzcat(varargin)
    % Horizontal concatenation for sym arrays.
    %   C = HORZCAT(A, B, ...) horizontally concatenates the symbolic
    %   variable arrays A, B, ... .  For matrices, all inputs must have the
    %   same number of rows.  
    %
    %   C = HORZCAT(A,B) is called for the syntax [A B].
    %
    %   See also VERTCAT.
    
    X = cellfun(@(x)SymVariable(x),varargin,'UniformOutput',false);
        %     X = SymExpression(varargin);
    str = cellfun(@(x)eval_math(['ToMatrixForm@',x.s]),X,'UniformOutput',false);
    % evaluate the operation in Mathematica and return the
    % expression string
    sstr = eval_math(['Join[' implode(str, ', ') ',2]']);
    
    % create a new object with the evaluated string
    y = SymVariable(SymExpression(sstr));

end