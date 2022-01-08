function obj = updateProp(obj, props)
    % This function updates the properties of the class object based on the
    % input name-value pair arguments.
    %
    % Parameters:
    %  varargin: variable nama-value pair input arguments, in detail:
    %   lb: lower limit @type colvec
    %   ub: upper limit @type colvec
    %  @type rowvec
    
    arguments
        obj
        props.lb (:,1) double {mustBeReal,mustBeNonNan} = []
        props.ub (:,1) double {mustBeReal,mustBeNonNan} = []
        props.AuxData cell = {}
    end
    
    % set boundary values
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
    
    if ~isempty(props.AuxData)
        obj = setAuxdata(obj, props.AuxData);
    end
    
    
end