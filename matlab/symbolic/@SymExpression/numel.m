function y = numel(obj)
    % Number of elements in a sym array.
    %   N = NUMEL(A) returns the number of elements in the sym array A.
    %
    %   See also SYM, SIZE.
    
    y = builtin('numel',obj);
    %     if isempty(obj.s)
    %         y = 0;
    %         return;
    %     end
    %
    %     y = eval_math(['Dimensions[ToVectorForm@',obj.s,']'],'math2matlab');

    
end
