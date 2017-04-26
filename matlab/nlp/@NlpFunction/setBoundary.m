function obj = setBoundary(obj, lowerbound, upperbound)
    % set the upper/lower boundary values of the function if they
    % exist
    %
    %
    % @note If the boundary values are not specified, then use -Inf/Inf by
    % default.
    % 
    % @note If the NLP function is a vector (Dimension > 1) but the
    % lower/upper bound values are specified as a scalar, we set the
    % lower/upper bounds of all element with the same scalar value.
    %
    % @note Ignore a particular boundary if it is given as empty
    %
    % Parameters:
    % lowerbound: the lower boundary values @type colvec
    % upperbound: the upper boundary values @type colvec

    
    
   
        
    
    if ~isempty(lowerbound)
        % expand the lower/upper limits if they are given as scalar values
        if isscalar(lowerbound)
            lowerbound = lowerbound*ones(obj.Dimension,1);
        end
        validateattributes(lowerbound,{'double'},...
            {'vector','numel',obj.Dimension,'real'},...
            'NlpFunction.SetBoundary','lowerbound');
        obj.LowerBound = lowerbound(:);
        
    end
    
    if ~isempty(upperbound)
        if isscalar(upperbound)
            upperbound = upperbound*ones(obj.Dimension,1);
        end
        
        
        validateattributes(upperbound,{'double'},...
            {'vector','numel',obj.Dimension,'real'},...
            'NlpFunction.SetBoundary','upperbound');
        
        % specifies lower/upper limits
        obj.UpperBound = upperbound(:);
    end
    
    assert(any(obj.UpperBound >= obj.LowerBound),...
        'The lowerbound is greater than the upper bound. NlpFunction name: %s\n', obj.Name);
end