function [y_des, extra] = calcDesiredOutputs(obj, t, qe, dqe)
    % Calculates the desired outputs of the domain
    %   
    % 
    % Parameters: 
    %  t: time @type double
    %  qe: joint configuration @type colvec
    %  dqe: joint velocities @type colvec
    
    y_des = struct('yd1', [], ...
        'Dyd1', [], ...
        'yd2', [], ...
        'Dyd2', [], ...
        'DLfyd2', []);
    
    extra = struct('tau', [], ...
        'dtau', []);
    
    %% phase variables
    switch obj.PhaseVariable.Type
        case 'StateBased'
            % if state-based outputs, use MEX functions to compute
            % compute phase variable first
            p = obj.Parameters.p;
            pvar = obj.PhaseVariable.Var;
            if isempty(p)
                tau = feval(pvar.Funcs.Kin, qe);
                tau_jac  = feval(pvar.Funcs.Jac, qe);
                tau_jacdot  = feval(pvar.Funcs.JacDot, qe, dqe);
            else
                tau = feval(pvar.Funcs.Kin, qe, p);
                tau_jac  = feval(pvar.Funcs.Jac, qe, p);
                tau_jacdot  = feval(pvar.Funcs.JacDot, qe, dqe, p);
            end
            dtau  = tau_jac*dqe;
            
            
            Jtau  = [tau_jac, zeros(size(tau_jac))];
            dJtau = [tau_jacdot, tau_jac];
            
        case 'TimeBased'            
            % if the desired outputs are time based, then assume time t as
            % a part of system state vector, and correspondingly add rows
            % associated with time 't' and 'dt' (which is 1)
            ndof = length(qe);
            tau   = t;
            dtau  = 1;
            Jtau  = [1, zeros(1, ndof), ...
                0, zeros(1,ndof)];
            dJtau = [0, zeros(1,ndof), ...
                1, zeros(1,ndof)];
    end
    
    extra.tau = tau;
    extra.dtau = dtau;
    %% compute desired outputs
    % compute relative degree one output
    if ~isempty(obj.ActVelocityOutput)
        v = obj.Parameters.v;
        y_des.yd1  = feval(obj.DesVelocityOutput.Funcs.y, tau, v);
        dy_d1      = feval(obj.DesVelocityOutput.Funcs.dy, tau, v);
        % chain rule
        y_des.Dyd1 = dy_d1*Jtau;
    end
    
    % compute relative degree two outputs
    a = obj.Parameters.a(:);
    y_des.yd2  = feval(obj.DesPositionOutput.Funcs.y, tau, a);
    dy_d2      = feval(obj.DesPositionOutput.Funcs.dy, tau, a);
    ddy_d2     = feval(obj.DesPositionOutput.Funcs.ddy, tau, a);
 
    
    % chain rule to compute jacobian
    y_des.Dyd2   = dy_d2*Jtau;
    y_des.DLfyd2 = ddy_d2*dtau*Jtau + dy_d2*dJtau;
        
    
end