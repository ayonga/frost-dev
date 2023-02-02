function yd = calcDesired(obj, t, x, dx, a, p)
    % calculate the desired outputs
    %
    % Parameters:
    % t: the time @type double
    % x: the states @type colvec
    % dx: the first order derivatives @type colvec
    % a: the parameters of the desired output @type matrix
    % p: the parameters of the phase variable @type colvec
    %
    % Return values:
    % yd: variable outputs in the following order:
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
    yd_funcs = obj.DesiredFuncsName_;
    
    
    assert(~isempty(yd_funcs),...
        'The functions for desired outputs are not defined. Please run compile(obj, varargin) first.');
    rel_deg = obj.RelativeDegree;
    yd = cell(1,rel_deg+1);
    is_state_based = strcmp(obj.PhaseType, 'StateBased'); 
    
    switch model_type
        case 'FirstOrder'
            states = {x};
        case 'SecondOrder'
            states = {x,dx};
    end
    
    if obj.hasPhaseParam 
        params = {a(:), p(:)};
        tau = calcPhaseVariable(obj, t, x, dx, p);
    else
        params = {a(:)};
        tau = calcPhaseVariable(obj, t, x, dx);
    end

    if tau{1} < 0
        s = 1;
    elseif tau{1} > 1
        s = obj.NumSegment;
    else
        s = discretize(tau{1},0:1/obj.NumSegment:1);
    end
    % compute the derivatives
    if is_state_based
        
        yd{1} = feval(yd_funcs{1,s}, x, params{:});
        if rel_deg > 1
            for i=2:rel_deg
                yd{i} = feval(yd_funcs{i,s}, states{:}, params{:});    %#ok<*AGROW>
            end
        end
        yd{rel_deg+1} = feval(yd_funcs{rel_deg+1,s}, states{:}, params{:});
        
    else
        yd{1} = feval(yd_funcs{1,s}, t, params{:});
        if rel_deg > 1
            for i=2:rel_deg
                yd{i} = feval(yd_funcs{i,s}, t, params{:});    %#ok<*AGROW>
            end
        end
        yd{rel_deg+1} = feval(yd_funcs{rel_deg+1,s}, t, params{:});
    end
    
end
