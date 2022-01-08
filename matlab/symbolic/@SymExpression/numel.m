function y = numel(obj)
    % Number of elements in a sym array.
    %   N = NUMEL(A) returns the number of elements in the sym array A.
    %
    %   See also SYM, SIZE.
    
    y = builtin('numel',obj); %%%MUST Use this, otherwise subsref and subsasgn will not work!!
end
