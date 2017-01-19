function obj = setBoundaryValue(obj, cl, cu)
    % set the upper/lower boundary values of the function if they
    % exist
    %
    % Parameters:
    %  cl: the lower boundary
    %  cu: the upper boundary

    if nargin > 1
        if isscalar(cl)
            obj.LowerBound = cl*ones(obj.Dimension,1);
        end
    end

    if nargin > 2
        if isscalar(cu)
            obj.UpperBound = cu*ones(obj.Dimension,1);
        end
    end

end