function ya = calcActual(obj, x, dx, offset)
    % calculate the actual outputs
    %
    % Parameters:
    % x: the states @type colvec
    % dx: the first order derivatives @type colvec
    %
    % Return values:
    % ya: variable outputs in the following order:
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
    ya_funcs = obj.ActualFuncsName_;
    
    assert(~isempty(ya_funcs),...
        'The functions for actual outputs are not defined. Please run compile(obj, varargin) first.');
    rel_deg = obj.RelativeDegree;
    ya = cell(1,rel_deg+1);
    
    if obj.Holonomic
        % holonomic virtual constraints
        % compute the actual output
        if obj.hasOffset
            ya{1} = feval(ya_funcs{1}, x, offset);
        else
            ya{1} = feval(ya_funcs{1}, x);
        end
    else
        if obj.hasOffset
            % non-holonomic virtual constraints
            ya{1} = feval(ya_funcs{1}, x, dx, offset);
        else
            ya{1} = feval(ya_funcs{1}, x, dx);
        end
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
            ya{i} = feval(ya_funcs{i}, states{:});                 %#ok<*AGROW>
        end
    end
    ya{rel_deg+1} = feval(ya_funcs{rel_deg+1}, states{:});
    
    
    
    
end