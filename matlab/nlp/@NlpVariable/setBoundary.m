function obj = setBoundary(obj, lowerbound, upperbound)
    % Sets the lower/upper boundary value for a NLP variable
    %
    % @note If the boundary values are not specified, then use -Inf/Inf by
    % default.
    % 
    % @note If the NLP variable is a vector (Dimension > 1) but the
    % lower/upper bound values are specified as a scalar, we set the
    % lower/upper bounds of all element with the same scalar value.
    %
    % @note Ignore a particular boundary if it is given as empty
    %
    % Parameters:
    % lowerbound: the lower boundary values @type colvec
    % upperbound: the upper boundary values @type colvec
    
    
    if nargin < 2
        lowerbound = -Inf;
        warning('NlpVariable:checkArgs',...
            'Lower limit not specified, automatically set to -Inf.');
    end
    if nargin < 3
        upperbound = Inf;
        warning('NlpVariable:checkArgs',...
            'Upper limit not specified, automatically set to Inf.');
    end
        
    
    if ~isempty(lowerbound)
        % expand the lower/upper limits if they are given as scalar values
        if isscalar(lowerbound)
            lowerbound = lowerbound*ones(obj.Dimension,1);
        end
        assert(isvector(lowerbound),...
            'NlpVariable:wrongDimension',...
            'The lower limit should be a vector or a scalar');
        if size(lowerbound,1) == 1
            obj.LowerBound = transpose(lowerbound); % make column vector
        else
            obj.LowerBound = lowerbound;
        end
    end
    
    if ~isempty(upperbound)
        if isscalar(upperbound)
            upperbound = upperbound*ones(obj.Dimension,1);
        end
        
        
        assert(isvector(upperbound),...
            'NlpVariable:wrongDimension',...
            'The upper limit should be a vector or a scalar');
        
        % specifies lower/upper limits
        
        if size(upperbound,1) == 1
            obj.UpperBound = transpose(upperbound); % make column vector
        else
            obj.UpperBound = upperbound;
        end
    end
    
    assert(all(obj.UpperBound >= obj.LowerBound),...
        'Invalid boundary values. The lowerbound is greater than the upper bound.');
end