function tau = calcPhaseVariable(obj, t, x, dx, p)
    % calculate the phase variable
    %
    % Parameters:
    % t: the time @type double
    % x: the states @type colvec
    % dx: the first order derivatives @type colvec
    % p: the parameter set @type colvec
    %
    % Return values:
    % tau: variable outputs in the following order:
    %  tau: the phase variable value @type double
    %  d1tau: the first order derivative @type double
    %  ...
    %  dNtau: the N = RelativeDegree - 1 order derivative @type double
    %  JdNtau: the Jacobian of dNya w.r.t. to the states @type rowvec
    %
    % @note: the last Jacobian output is the Jacobian of the dNya with
    % respoect to the states, which is [x] for a first order system and
    % [x;dx] for a second order system.
    
    
    
    rel_deg = obj.RelativeDegree;
    tau = cell(1,rel_deg+1);
    if strcmp(obj.PhaseType, 'TimeBased')
        tau{1} = (t - p(2)) / (p(1) - p(2));
        [tau{2:rel_deg+1}] = deal(1);
        disp(['Current Tau value is ', num2str(tau{1})])
        return;
    else % StateBased
        if isempty(obj.tau_)
            return;
        end
    end
    
    model_type = obj.Model.Type;
    tau_funcs = obj.PhaseFuncsName_;
    assert(~isempty(tau_funcs),...
        'The functions for the phase variable are not defined. Please run compile(obj, varargin) first.');
    
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
    
    
    
    tau{1} = feval(tau_funcs{1}, x, params{:});
    disp(['Current Tau value is ', num2str(tau{1})])
    
    if rel_deg > 1
        for i=2:rel_deg
            tau{i} = feval(tau_funcs{i}, states{:}, params{:});                 %#ok<*AGROW>
        end
    end
    tau{rel_deg+1} = feval(tau_funcs{rel_deg+1}, states{:}, params{:});
  
end