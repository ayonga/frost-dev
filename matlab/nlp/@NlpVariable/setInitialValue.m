function obj = setInitialValue(obj, x)
    % Sets a typical initial value for the NLP variables. This value will
    % be used to assign the initial value for the NLP solver.
    %
    % @note If the initial value is not given, then use the middle value of
    % the lower/upper boundaries.
    %
    % Parameters: 
    % x: an array of initial value of the NLP variables @type colvec
    
    % determine the typical value
    if nargin > 1
        
        if isscalar(x)
            x = x*ones(obj.Dimension,1);
        else
            if isrow(x)
                x = transpose(x);
            end
            validateattributes(x,{'double'},...
                {'vector','numel',obj.Dimension,'real'},...
                'NlpVariable.setInitialValue','InitialValue');
        end
        obj.InitialValue = x;
    else 
        % preallocate
        
        lb_tmp = obj.LowerBound;
        ub_tmp = obj.UpperBound;
        
        % replace infinity with very high numbers
        lb_tmp(lb_tmp==-inf) = -1e5;
        ub_tmp(ub_tmp==inf)  = 1e5;
        
        obj.InitialValue = (ub_tmp + lb_tmp)/2;
    end
    
end