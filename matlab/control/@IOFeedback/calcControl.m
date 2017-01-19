function [u, extra] = calcControl(obj, t, qe, dqe, vfc, gfc, domain)
    % Computes the classical input-output feedback linearization
    % control law for virtual constraints
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
    
    
    % compute actual and desired outputs
    y_act = calcActualOutputs(domain, qe, dqe);
    y_des = calcDesiredOutputs(domain, t, qe, dqe);

    y1    = y_act.ya1 - y_des.yd1;
    Dy1   = y_act.Dya1 - y_des.Dyd1;


    y2    = y_act.ya2 - y_des.yd2;
    Dy2   = y_act.Dya2 - y_des.Dyd2;
    DLfy2 = y_act.DLfya2 - y_des.DLfyd2;






    if isempty(y1) % no relative degree one output case

        % First Order Lie Derivatives
        Lfy2 = Dy2*vfc;
        % Second Order Lie Derivatives
        LfLfy2 = DLfy2*vfc;
        LgLfy2 = DLfy2*gfc;

        % decoupling matrix
        A_mat  = LgLfy2;
        % feedforward term
        Lf_mat = LfLfy2;

        % auxilary control input
        mu = - obj.Param.kd * Lfy2 - obj.Param.kp * y2;
    else
        % First Order Lie Derivatives
        Lfy1 = Dy1*vfc;
        Lgy1 = Dy1*gfc;
        Lfy2 = Dy2*vfc;
        % Second Order Lie Derivatives
        LfLfy2 = DLfy2*vfc;
        LgLfy2 = DLfy2*gfc;
        % decoupling matrix
        A_mat  = [Lgy1; LgLfy2];
        % feedforward term
        Lf_mat = [Lfy1; LfLfy2];

        % auxilary control input
        mu = [-(obj.Param.kd/2)*y1;
            - obj.Param.kd * Lfy2 - obj.Param.kp * y2];

    end

    % feedback controller
    u = A_mat \ (- Lf_mat + mu);

    if nargout > 1
        extra = struct;
        extra.mu = mu;
        extra.y1 = y1;
        extra.y2 = y2;        
        extra.Lfy2 = Lfy2;
        
        extra.ya1 = y_act.ya1;
        extra.yd1 = y_des.yd1;
        
        extra.ya2 = y_act.ya2;
        extra.yd2 = y_des.yd2;
        
        extra.ya2dot = y_act.Dya2 * vfc;
        extra.yd2dot = y_des.Dyd2 * vfc;
        
        extra.tau = y_des.tau;
        extra.dtau = y_des.dtau;
        
        
    end

end