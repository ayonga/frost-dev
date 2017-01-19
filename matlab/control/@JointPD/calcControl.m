function [u, extra] = calcControl(obj, t, qe, dqe, vfc, gfc, domain)
    % Computes the PD feedback control law on joint space
    %
    % Parameters:
    % t: the time instant @type double
    % qe: the joint configuration @type colvec
    % dqe: the joint velocities @type colvec
    % vfc: the vector field f(x) @type colvec
    % gfc: the vector field g(x) @type colvec
    % domain: the continuous domain @type Domain
    %
    % Return values:
    % u: the computed torque @type colvec
    % extra: additional computed data @type struct
    

    [qd, dqd] = calcDesiredStates(domain, t, qe, dqe);
    
    % compute error terms
    qerr = qa - qd;
    dqerr = dqa - dqd;

    % feedback controller
    u = - obj.Params.kp*qerr - obj.Params.kd*dqerr;

    if narargout > 1
        extra = struct;
        extra.qerr  = qerr;
        extra.dqerr = dqerr;
    end

end