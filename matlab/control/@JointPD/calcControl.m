function [u, extra] = calcControl(obj, qa, dqa, qd, dqd, Be)
    % Computes the PD feedback control law on joint space
    %
    % Parameters:
    % qa: the actual joint configuration @type colvec
    % dqa: the actual joint velocities @type colvec
    % qd: the desired joint configuration @type colvec
    % dqd: the desired joint velocities @type colvec
    % Be: the torque distribution matrix @type matrix
    %
    % Return values:
    % u: the computed torque @type colvec
    % extra: additional computed data @type struct
    

    % compute error terms
    qerr = qa - qd;
    dqerr = dqa - dqd;

    % feedback controller
    u = Be*(- obj.Params.kp*qerr - obj.Params.kd*dqerr);

    if narargout > 1
        extra = struct;
        extra.qerr = qerr;
        extra.dqerr = dqerr;
    end

end