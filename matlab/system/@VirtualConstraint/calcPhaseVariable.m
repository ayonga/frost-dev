function varargout = calcPhaseVariable(obj, t, x, dx, p)
    % calculate the phase variable
    %
    % Parameters:
    % x: the states @type colvec
    % dx: the first order derivatives @type colvec
    % p: the parameter set @type colvec
    %
    % Return values:
    % varargout: variable outputs in the following order:
    %  tau: the phase variable value @type double
    %  d1tau: the first order derivative @type double
    %  ...
    %  dNtau: the N = RelativeDegree - 1 order derivative @type double
    %  JdNtau: the Jacobian of dNya w.r.t. to the states @type rowvec
    %
    % @note: the last Jacobian output is the Jacobian of the dNya with
    % respoect to the states, which is [x] for a first order system and
    % [x;dx] for a second order system.
    
    
    if strcmp(obj.PhaseType, 'TimeBased')
        varargout{1} = t;
        [varargout{2:nargout}] = deal(1);
        return;
    end
    model_type = obj.Model.Type;
    tau_funcs = obj.PhaseFuncsName_;
    assert(~isempty(tau_funcs),...
        'The functions for the phase variable are not defined. Please run compile(obj, varargin) first.');
    rel_deg = obj.RelativeDegree;
    if obj.hasPhaseParam
        params = {p(:)};
    else
        params = {};
    end
    
    switch model_type
        case 'FirstOrder'
            states = {x};
        case 'SecondOrder'
            states = {x,dx};
    end
    
    
    
    varargout{1} = feval(tau_funcs{1}, x, params{:});
    if rel_deg > 1
        for i=2:rel_deg
            varargout{i} = feval(tau_funcs{i}, states{:}, params{:});                 %#ok<*AGROW>
        end
    end
    varargout{rel_deg+1} = feval(tau_funcs{rel_deg+1}, states{:}, params{:});
    
end