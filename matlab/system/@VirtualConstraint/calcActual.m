function varargout = calcActual(obj, x, dx)
    % calculate the actual outputs
    %
    % Parameters:
    % x: the states @type colvec
    % dx: the first order derivatives @type colvec
    %
    % Return values:
    % varargout: variable outputs in the following order:
    %  ya: the actual output value @type colvec
    %  d1ya: the first order derivative @type colvec
    %  ...
    %  dNya: the N = RelativeDegree - 1 order derivative @type colvec
    %  JdNya: the Jacobian of dNya w.r.t. to the states @type matrix
    %
    % @note: the last Jacobian output is the Jacobian of the dNya with
    % respoect to the states, which is [x] for a first order system and
    % [x;dx] for a second order system.
    
    model_type = obj.Model.Type;
    ya_funcs = obj.ActualFuncs;
    assert(~isempty(ya_funcs),...
        'The functions for actual outputs are not defined. Please run compile(obj, varargin) first.');
    rel_deg = obj.RelativeDegree;
    
    
    if obj.Holonomic
        % holonomic virtual constraints
        % compute the actual output
        varargout{1} = feval(ya_funcs{1}.Name, x);
    else
        % non-holonomic virtual constraints
        varargout{1} = feval(ya_funcs{1}.Name, x, dx);
        
    end
    
    switch model_type
        case 'FirstOrder'
            states = {x};
        case 'SecondOrder'
            states = {x,dx};
    end
    
    % compute high-order derivatives
    if rel_deg > 1
        for i=2:rel_deg
            varargout{i} = feval(ya_funcs{i}.Name, states{:});                 %#ok<*AGROW>
        end
    end
    varargout{rel_deg+1} = feval(ya_funcs{rel_deg+1}.Name, states{:});
    
    
    
    
end