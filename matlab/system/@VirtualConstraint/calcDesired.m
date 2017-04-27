function varargout = calcDesired(obj, t, x, dx, a, p)
    % calculate the desired outputs
    %
    % Parameters:
    % t: the time @double
    % x: the states @type colvec
    % dx: the first order derivatives @type colvec
    % a: the parameters of the desired output @type matrix
    % p: the parameters of the phase variable @type colvec
    %
    % Return values:
    % varargout: variable outputs in the following order:
    %  yd: the actual output value @type colvec
    %  d1yd: the first order derivative @type colvec
    %  ...
    %  dNyd: the N = RelativeDegree - 1 order derivative @type colvec
    %  JdNyd: the Jacobian of dNya w.r.t. to the states @type matrix
    %
    % @note: the last Jacobian output is the Jacobian of the dNyd with
    % respoect to the states, which is [x] for a first order system and
    % [x;dx] for a second order system.
    
    model_type = obj.Model.Type;
    yd_funcs = obj.DesiredFuncs;
    
    
    assert(~isempty(yd_funcs),...
        'The functions for desired outputs are not defined. Please run compile(obj, varargin) first.');
    rel_deg = obj.RelativeDegree;
    is_state_based = strcmp(obj.PhaseType, 'StateBased');
    
    if ~isempty(obj.PhaseParams) && is_state_based
        params = {a(:), p(:)};
    else
        params = {a(:)};
    end
    
    
    
    switch model_type
        case 'FirstOrder'
            states = {x};
        case 'SecondOrder'
            states = {x,dx};
    end
    
    % compute the derivatives
    if is_state_based
        
        varargout{1} = feval(yd_funcs{1}.Name, x, params{:});
        if rel_deg > 1
            for i=2:rel_deg
                varargout{i} = feval(yd_funcs{i}.Name, states{:}, params{:});    %#ok<*AGROW>
            end
        end
        varargout{rel_deg+1} = feval(yd_funcs{rel_deg+1}.Name, states{:}, params{:});
        
    else
        varargout{1} = feval(yd_funcs{1}.Name, t, params{:});
        if rel_deg > 1
            for i=2:rel_deg
                varargout{i} = feval(yd_funcs{i}.Name, t, params{:});    %#ok<*AGROW>
            end
        end
        varargout{rel_deg+1} = feval(yd_funcs{rel_deg+1}.Name, t, params{:});
    end
    
end