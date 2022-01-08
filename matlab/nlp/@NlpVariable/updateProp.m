function obj = updateProp(obj, props)
    % This function updates the properties of the class object based on the
    % input name-value pair arguments.
    %
    % Parameters:
    % varargin: variable nama-value pair input arguments, in detail:
    % lb: lower limit @type colvec
    % ub: upper limit @type colvec
    % x0: a typical value of the variable @type colvec
    
    arguments
        obj
        props.lb (:,1) double {mustBeReal,mustBeNonNan} = []
        props.ub (:,1) double {mustBeReal,mustBeNonNan} = []
        props.x0 (:,1) double {mustBeReal,mustBeNonNan} = []
    end
    
    lowerbound = props.lb;
    if ~isempty(lowerbound)
        % expand the lower/upper limits if they are given as scalar values
        if isscalar(lowerbound)
            lowerbound = lowerbound*ones(obj.Dimension,1);
        else
            assert(length(lowerbound) == obj.Dimension, ...
                'The `lb` must be a scalar or a vector with the length that equals the dimension of the `NlpVariable` object.');           
        end
        
        obj.LowerBound = lowerbound;
    end
    
    upperbound = props.ub;
    if ~isempty(upperbound)
        if isscalar(upperbound)
            upperbound = upperbound*ones(obj.Dimension,1);
        else
            assert(length(upperbound) == obj.Dimension, ...
                'The `ub` must be a scalar or a vector with the length that equals the dimension of the `NlpVariable` object.');             
        end
        % specifies lower/upper limits
        
        obj.UpperBound = upperbound;        
    end
    
    if ~isempty(obj.UpperBound) && ~isempty(obj.LowerBound)
        assert(any(obj.UpperBound >= obj.LowerBound),...
            'The lowerbound is greater than the upper bound. Variable name: %s\n', obj.Name);
    end
    
    x0 = props.x0;
    if ~isempty(x0)
        
        if isscalar(x0)
            x0 = x0*ones(obj.Dimension,1);
        else
            assert(length(x0) == obj.Dimension, ...
                'The `x0` must be a scalar or a vector with the length that equals the dimension of the `NlpVariable` object.');             
        end
        obj.InitialValue = x0;
    else 
        % preallocate
        if ~isempty(obj.UpperBound) && ~isempty(obj.LowerBound) && isempty(obj.InitialValue)
            lb_tmp = obj.LowerBound;
            ub_tmp = obj.UpperBound;
            
            % replace infinity with very high numbers
            lb_tmp(lb_tmp==-inf) = -1e4;
            ub_tmp(ub_tmp==inf)  = 1e4;
            
            obj.InitialValue = (ub_tmp - lb_tmp).*rand(obj.Dimenion,1) + lb_tmp;
        end
    end
    

end